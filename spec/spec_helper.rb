require "bundler/setup"
require "vault"
require "rubyconfig/vault"
require_relative "support/vault_server"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

def vault_source
  Config::Sources::VaultSource.new(
    address: RSpec::VaultServer.address,
    token: RSpec::VaultServer.token
  )
end

def vault_client
  Vault::Client.new(
    address: RSpec::VaultServer.address,
    token: RSpec::VaultServer.token
  )
end
