require 'rubygems'
require 'rspec'
require 'rspec/autorun'
require 'mocha'

require 'tmpdir'

require 'pull_request_bot'

RSpec.configure do |config|
  config.mock_with :mocha
end

def read_fixture(file)
  File.read(File.join(File.dirname(__FILE__), 'fixtures', file))
end

def populate_template_dir(template_dir, fixture_path)
  FileUtils.mkdir_p template_dir
  FileUtils.cp_r(File.join(File.dirname(__FILE__), 'fixtures', 'templates', fixture_path, '.'), template_dir)
end
