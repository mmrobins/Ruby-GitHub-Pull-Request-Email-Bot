require 'rubygems'
require 'rspec'
require 'mocha'

require 'tmpdir'

require 'pull_request_bot'

RSpec.configure do |config|
  config.mock_with :mocha
end
