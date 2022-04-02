require_relative 'lib/rubyconfig/vault/version'

Gem::Specification.new do |spec|
  spec.name          = "rubyconfig-vault"
  spec.version       = Rubyconfig::Vault::VERSION
  spec.authors       = ["David Young"]
  spec.email         = ["da.young@f5.com"]

  spec.summary       = 'Implements a ruby config source from vault'
  spec.homepage      = 'https://github.com/CrunchwrapSupreme/rubyconfig-vault'
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["allowed_push_host"] = 'https://rubygems.org'

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = 'https://github.com/CrunchwrapSupreme/rubyconfig-vault'
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir['lib/**/*.rb']
  spec.add_runtime_dependency "vault", "~> 0.16.0"
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
