require 'rubygems'
require 'rspec'
require 'mocha'

require 'tmpdir'

require 'pull_request_bot'

RSpec.configure do |config|
  config.mock_with :mocha
end

def read_fixture(file)
  File.read(File.join(File.dirname(__FILE__), 'fixtures', file))
end
