[![Ruby Tests](https://github.com/CrunchwrapSupreme/rubyconfig-vault/actions/workflows/ruby-test.yml/badge.svg?branch=main)](https://github.com/CrunchwrapSupreme/rubyconfig-vault/actions/workflows/ruby-test.yml)
[![Gem Version](https://badge.fury.io/rb/rubyconfig-vault.svg)](https://badge.fury.io/rb/rubyconfig-vault)
# Rubyconfig::Vault

This gem is provided to support vault sources in rubyconfig installations.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rubyconfig-vault'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install rubyconfig-vault

## Usage

For more authentication methods see ruby documentation for https://github.com/hashicorp/vault-ruby

```ruby
require 'rubyconfig/vault'

auth_secret = Vault.auth.approle('roleid', 'secret id')
source = Config::Sources::VaultSource(address: ENV['VAULT_ADDR'], 
                                      token: auth_secret.auth.client_token,
                                      paths: ['kvp/secret'])
                                      
# The ** operator scans all child keys of kvp/ for sub-keys of 'test'
source.add_path('kvp/**/test')

# The * operator assigns all values at path and the values of immediate child keys
source.add_path('kvp/*')

# Or combine the two...
source.add_path('kvp/**/some/keys/*')

Settings.add_source!(source)
Settings.reload!
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/CrunchwrapSupreme/rubyconfig-vault.

