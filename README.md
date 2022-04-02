[![Ruby Tests](https://github.com/CrunchwrapSupreme/rubyconfig-vault/actions/workflows/ruby-test.yml/badge.svg?branch=main)](https://github.com/CrunchwrapSupreme/rubyconfig-vault/actions/workflows/ruby-test.yml)
[![Gem Version](https://badge.fury.io/rb/rubyconfig-vault.svg)](https://badge.fury.io/rb/rubyconfig-vault)
![Gem Downloads](https://img.shields.io/gem/dt/rubyconfig-vault)

# Ruby Config Vault Source

This gem is provided to support vault sources in [rubyconfig/config](https://github.com/rubyconfig/config) installations. Further documentation can be found at [rubydoc.info](https://www.rubydoc.info/gems/rubyconfig-vault/Config).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'config'
gem 'rubyconfig-vault'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install rubyconfig-vault

## Usage

For more vault authentication methods see ruby documentation for https://github.com/hashicorp/vault-ruby and for additional rubyconfig configuration options see https://github.com/rubyconfig/config.

```ruby
require 'config'
require 'config/vault'

auth_secret = Vault.auth.approle('roleid', 'secret id')
source = Config::Sources::VaultSource.new(address: ENV['VAULT_ADDR'], 
                                          token: auth_secret.auth.client_token,
                                          paths: ['kvp/secret'])
                                      
# The * operator retrieves values at kvp/ and the values of immediate child keys
source.add_path('kvp/*')

# The ** operator scans all child keys of kvp/ for sub-keys containing 'test'
source.add_path('kvp/**/test')

# Or combine the two...
source.add_path('kvp/**/some/keys/*')

Config.load_and_set_settings(source)

# Alternatively to reload after loading yaml configuration...
# Settings.add_source!(source)
# Settings.reload!

# 'kvp/secret'
puts Settings.kvp.secret

# 'kvp/*'
puts Settings.kvp.some_value
puts Settings.kvp.rando.some_value

# 'kvp/**/test'
puts Settings.kvp.rando.test.some_value
puts Settings.kvp.rando2.test.some_value

# 'kvp/**/some/keys/*'
puts Settings.kvp.rando3.some.keys.some_value
puts Settings.kvp.rando4.some.keys.test2.some_value
```

Valid options for `Config::Sources::VaultSource.new` include all the configuration options provided by `Vault::Client.new` and the following:
- `:root` set a root key under which all keys from this source will be located
- `:kv` set the mount point
- `:paths` a list of valid paths for keys

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment. 

Follow https://www.vaultproject.io/docs/install to install vault as development dependency and then run `rake`. Alternatively leverage the provided Dockerfile using `rake docker:build` and `rake docker:spec` to run tests.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/CrunchwrapSupreme/rubyconfig-vault.

