require_relative 'lib/config/vault/version'

Gem::Specification.new do |spec|
  spec.name          = "rubyconfig-vault"
  spec.version       = Config::Vault::VERSION
  spec.authors       = ["David Young"]
  spec.email         = ["da.young@f5.com"]

  spec.summary       = 'Implements a ruby config source from vault'
  spec.homepage      = 'https://github.com/CrunchwrapSupreme/rubyconfig-vault'
  spec.required_ruby_version = Gem::Requirement.new(">= 2.6.0")

  spec.metadata["allowed_push_host"] = 'https://rubygems.org'
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = 'https://github.com/CrunchwrapSupreme/rubyconfig-vault'
  spec.metadata["documentation_uri"] = 'https://www.rubydoc.info/gems/rubyconfig-vault/index'

  spec.files         = ['lib/config/vault.rb', 'lib/config/vault/vault_source.rb', 'lib/config/vault/version.rb', 'lib/config/vault/vault_error.rb']
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.add_runtime_dependency "vault", "~> 0.16.0"
  spec.add_runtime_dependency "config", "~> 4.0.0"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry"
end
