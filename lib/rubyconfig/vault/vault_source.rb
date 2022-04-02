require 'vault'

module Config
  module Sources
    class VaultSource
      attr_accessor :kv
      attr_reader :paths, :client

      def initialize(opts = {})
        client_opts = opts.clone
        @kv = client_opts.delete(:kv) || ''
        @paths = client_opts.delete(:paths) || []
        @client = Vault::Client.new(client_opts)
      end

      def add_path(path)
        @paths << path
      end

      def clear_paths
        @paths = []
      end

      def load
        process_paths
      end

      def client
        unless kv.empty?
          @client.kv(@kv)
        else
          @client.logical
        end
      end

      private

      def process_paths
        root = {}
        parsed_paths = @paths.map { |p| process_path(p) }
        parsed_paths.each { |p| root.merge!(p) }

        root
      end

      def process_path(path)
        root = {}
        subpaths = path.split('/')
        stack = []
        stack.push([nil, 0, root])

        while !stack.empty? do
          query_path, idx, parent = stack.pop
          sp = subpaths[idx]
          if sp.nil? || sp.eql?('*')
            data = client.read(query_path)&.data
            parent.merge!(data || {})
            parent.compact!
          end

          if sp.eql?('**') || sp.eql?('*')
            subtrees = client.list(query_path)
            subtrees.each do |st|
              new_parent = {}
              new_key = st.split('/').last.downcase.to_sym
              new_query_path = [query_path, st].join('/')
              parent[new_key] = new_parent
              stack.push([new_query_path, idx + 1, new_parent])
            end
          elsif sp
            query_path = [query_path, sp].compact.join('/')
            idx += 1
            new_parent = {}
            parent[sp.downcase.to_sym] = new_parent
            stack.push([query_path, idx, new_parent])
          end
        end

        root
      end

    end
  end
end
