require 'vault'

module Config
  module Sources
    # A vault source for Config
    class VaultSource
      attr_accessor :kv, :root, :flatten
      attr_reader :paths, :client

      # Create a new Config source, all Vault::Client parameters supported
      #
      # @param [Hash] opts
      # @option opts [String, nil] :kv mount point for operations
      # @option opts [Array<String>, nil] :paths paths for vault secrets
      # @option opts [String, Symbol, nil] :root default root key for data provided by source
      # @option opts [Integer] :attempts number of attempts to try and resolve Vault::HTTPError
      # @option opts [Number] :base interval for exponential backoff
      # @option opts [Number] :max_wait maximum weight time for exponential backoff
      # @option opts [Boolean] :flatten flatten the resulting hash. Preserves root option
      def initialize(opts = {})
        client_opts = opts.clone
        @kv = client_opts.delete(:kv) || ''
        @paths = []
        @attempts = client_opts.delete(:attempts) || 5
        @base = client_opts.delete(:base) || 0.5
        @max_wait = client_opts.delete(:max_wait) || 2.5
        @root = client_opts.delete(:root)
        @flatten = client_opts.delete(:flatten)
        @paths << client_opts.delete(:paths) if client_opts.key?(:paths)
        @map = {}
        @paths.map! do |p|
          if p.is_a?(Array)
            p
          else
            [p, @root]
          end
        end
        @client = ::Vault::Client.new(client_opts)
      end

      # Add a path to Config source
      #
      # @example Use glob operators
      #   source.add_path('secrets/**/test/*')
      #   source.load #=> { secrets: { some_key: { test: { secret_data: 2 } } } }
      #
      # @param path [String]
      # @param root [String] optional root
      def add_path(path, root = nil)
        root ||= @root
        @paths << [path, root]
      end

      # Re-map individual key names
      #
      # @param hsh [Hash] mappings for keys
      def map(hsh)
        @map = hsh
      end

      # Remove added paths
      def clear_paths
        @paths = []
      end

      # Load data from source into hash
      #
      # @return [Hash]
      def load
        Vault.with_retries(Vault::HTTPError,
                           attempts: @attempts,
                           base: @base,
                           max_wait: @max_wait) do
          process_paths
        end
      end

      private

      def client_ops
        unless kv.empty?
          @client.kv(@kv)
        else
          @client.logical
        end
      end

      def process_paths
        root = {}
        parsed_paths = @paths.map { |p| process_path(p) }
        parsed_paths.each { |p| root.merge!(p) }

        root
      end

      def process_path(path)
        root = {}
        subpaths = path.first.split('/')
        stack = []
        stack.push([nil, 0, root])

        while !stack.empty? do
          query_path, idx, parent = stack.pop
          sp = subpaths[idx]
          if sp.nil? || sp.eql?('*')
            data = client_ops.read(query_path)&.data || {}
            node = root if @flatten
            node = parent unless @flatten
            node.merge!(data)
            node.transform_keys! { |key| @map[key] || key }
            node.compact!
          end

          if sp.eql?('**') || sp.eql?('*')
            subtrees = client_ops.list(query_path)
            subtrees.each do |st|
              new_parent = {}
              new_key = st.split('/').last.downcase.to_sym
              new_query_path = [query_path, st].join('/')
              parent[new_key] = new_parent unless @flatten
              stack.push([new_query_path, idx + 1, new_parent])
            end
          elsif sp
            query_path = [query_path, sp].compact.join('/')
            idx += 1
            new_parent = {}
            parent[sp.downcase.to_sym] = new_parent unless @flatten
            stack.push([query_path, idx, new_parent])
          end
        end

        if path.last
          { @root => root }
        else
          root
        end
      end

    end
  end
end
