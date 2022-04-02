require 'spec_helper'
require 'config'

RSpec.describe Config::Sources::VaultSource do
  let(:client) { vault_client.kv('verionsed-kv') }
  let(:source) { vault_source }

  before(:context) do
    client = vault_client
    client.sys.mount(
      'versioned-kv',
      'kv',
      'v2 KV',
      options: { version: '2' }
    )
    client = client.kv('versioned-kv')
    client.write('test', { testkey1: 1 })
    client.write('test/test2', { testkey2: 2})
    client.write('test/test3/test', { testkey3: 3 })
    client.write('test/test4/test', { testkey4: 4 })
    client.write('test/test5/test/test', { testkey5: 5 })
  end

  after(:context) do
    vault_client.sys.unmount('versioned-kv')
  end

  before(:example) do
    source.kv = 'versioned-kv'
    source.clear_paths
  end

  it "should load absolute paths" do
    source.add_path('test')
    hsh = source.load
    expect(hsh.key?(:test)).to be(true)
    expect(hsh[:test].key?(:testkey1)).to be(true)
    expect(hsh.dig(:test, :testkey1)).to eql(1)
  end

  it "should load immediate keys and values with '*'" do
    source.add_path('test/*')
    hsh = source.load
    expect(hsh.dig(:test, :testkey1)).to eq(1)
    expect(hsh.dig(:test, :test2, :testkey2)).to eq(2)
  end

  it "should load values from keys at paths with '**'" do
    source.add_path('test/**/test')
    hsh = source.load
    expect(hsh.dig(:test, :test3, :test, :testkey3)).to eq(3)
    expect(hsh.dig(:test, :test4, :test, :testkey4)).to eq(4)
  end

  it "should load values from keys at paths with '**/*'" do
    source.add_path('test/**/test/*')
    hsh = source.load
    expect(hsh.dig(:test, :test3, :test, :testkey3)).to eq(3)
    expect(hsh.dig(:test, :test4, :test, :testkey4)).to eq(4)
    expect(hsh.dig(:test, :test5, :test, :test, :testkey5)).to eq(5)
  end

  it "should allow a root key to be set" do
    source.root = :vault
    source.add_path('test')
    hsh = source.load
    expect(hsh.dig(:vault, :test, :testkey1)).to eql(1)
  end

  it "should integrate with Config" do
    source.add_path('test')
    settings = Config.load_files(source)
    expect(settings.test.testkey1).to eq(1)
  end
end
