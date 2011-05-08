#!/usr/bin/env ruby

require 'spec_helper'

describe PullRequestBot do
  before :each do
    ARGV.clear
  end

  describe 'configuration file location' do
    before :each do
      File.stubs(:read).returns('')
      PullRequestBot.any_instance.stubs(:validate_config).returns true
    end

    it "should have a default of './config.yaml'" do
      bot = PullRequestBot.new

      bot.opts[:config].should == './config.yaml'
    end

    it "should set the location with the '-c /path/to/config.yaml' command line option" do
      ['-c', '/path/to/config.yaml'].each {|x| ARGV.push x}
      bot = PullRequestBot.new

      bot.opts[:config].should == '/path/to/config.yaml'
    end

    it "should set the location with the '--config /path/to/config.yaml' command line option" do
      ['--config', '/path/to/another/config.yaml'].each {|x| ARGV.push x}
      bot = PullRequestBot.new

      bot.opts[:config].should == '/path/to/another/config.yaml'
    end
  end

  describe 'with a configuration file' do
    before :each do
      @config_dir = Dir.mktmpdir
      @config_file = "#{@config_dir}/config.yaml"
      ['-c', @config_file].each {|x| ARGV.push x}
    end

    after :each do
      FileUtils.rm_rf @config_dir
    end

    describe 'reading' do
      it 'should require a default section' do
        write_config ''

        lambda { PullRequestBot.new }.should raise_error(
          ArgumentError, /there must be a 'default' section/
        )
      end

      it 'should require a default template_dir' do
        write_config <<-HERE
---
default:
  state_dir: ''
  to_email_address: ''
  from_email_address: ''
  reply_to_email_address: ''
  html_email: ''
  group_pull_request_updates: ''
  alert_on_close: ''
  opened_subject: ''
  closed_subject: ''
        HERE

        lambda { PullRequestBot.new }.should raise_error(
          ArgumentError, /'default' section must contain 'template_dir'/
        )
      end

      it 'should require a default state_dir' do
        write_config <<-HERE
---
default:
  template_dir: ''
  to_email_address: ''
  from_email_address: ''
  reply_to_email_address: ''
  html_email: ''
  group_pull_request_updates: ''
  alert_on_close: ''
  opened_subject: ''
  closed_subject: ''
        HERE

        lambda { PullRequestBot.new }.should raise_error(
          ArgumentError, /'default' section must contain 'state_dir'/
        )
      end

      it 'should require a default to_email_address' do
        write_config <<-HERE
---
default:
  template_dir: ''
  state_dir: ''
  from_email_address: ''
  reply_to_email_address: ''
  html_email: ''
  group_pull_request_updates: ''
  alert_on_close: ''
  opened_subject: ''
  closed_subject: ''
        HERE

        lambda { PullRequestBot.new }.should raise_error(
          ArgumentError, /'default' section must contain 'to_email_address'/
        )
      end

      it 'should require a default from_email_address' do
        write_config <<-HERE
---
default:
  template_dir: ''
  state_dir: ''
  to_email_address: ''
  reply_to_email_address: ''
  html_email: ''
  group_pull_request_updates: ''
  alert_on_close: ''
  opened_subject: ''
  closed_subject: ''
        HERE

        lambda { PullRequestBot.new }.should raise_error(
          ArgumentError, /'default' section must contain 'from_email_address'/
        )
      end

      it 'should require a default reply_to_email_address' do
        write_config <<-HERE
---
default:
  template_dir: ''
  state_dir: ''
  to_email_address: ''
  from_email_address: ''
  html_email: ''
  group_pull_request_updates: ''
  alert_on_close: ''
  opened_subject: ''
  closed_subject: ''
        HERE

        lambda { PullRequestBot.new }.should raise_error(
          ArgumentError, /'default' section must contain 'reply_to_email_address'/
        )
      end

      it 'should require a default html_email' do
        write_config <<-HERE
---
default:
  template_dir: ''
  state_dir: ''
  to_email_address: ''
  from_email_address: ''
  reply_to_email_address: ''
  group_pull_request_updates: ''
  alert_on_close: ''
  opened_subject: ''
  closed_subject: ''
        HERE

        lambda { PullRequestBot.new }.should raise_error(
          ArgumentError, /'default' section must contain 'html_email'/
        )
      end

      it 'should require a default group_pull_request_updates' do
        write_config <<-HERE
---
default:
  template_dir: ''
  state_dir: ''
  to_email_address: ''
  from_email_address: ''
  reply_to_email_address: ''
  html_email: ''
  alert_on_close: ''
  opened_subject: ''
  closed_subject: ''
        HERE

        lambda { PullRequestBot.new }.should raise_error(
          ArgumentError, /'default' section must contain 'group_pull_request_updates'/
        )
      end

      it 'should require a default alert_on_close' do
        write_config <<-HERE
---
default:
  template_dir: ''
  state_dir: ''
  to_email_address: ''
  from_email_address: ''
  reply_to_email_address: ''
  html_email: ''
  group_pull_request_updates: ''
  opened_subject: ''
  closed_subject: ''
        HERE

        lambda { PullRequestBot.new }.should raise_error(
          ArgumentError, /'default' section must contain 'alert_on_close'/
        )
      end

      it 'should require a default opened_subject' do
        write_config <<-HERE
---
default:
  template_dir: ''
  state_dir: ''
  to_email_address: ''
  from_email_address: ''
  reply_to_email_address: ''
  html_email: ''
  group_pull_request_updates: ''
  alert_on_close: ''
  closed_subject: ''
        HERE

        lambda { PullRequestBot.new }.should raise_error(
          ArgumentError, /'default' section must contain 'opened_subject'/
        )
      end

      it 'should require a default closed_subject when alert_on_close is true' do
        write_config <<-HERE
---
default:
  template_dir: ''
  state_dir: ''
  to_email_address: ''
  from_email_address: ''
  reply_to_email_address: ''
  html_email: ''
  group_pull_request_updates: ''
  alert_on_close: true
  opened_subject: ''
        HERE

        lambda { PullRequestBot.new }.should raise_error(
          ArgumentError, /'default' section must contain 'closed_subject'/
        )
      end

      it 'should not require a default closed_subject when alert_on_close is false' do
        write_config <<-HERE
---
default:
  template_dir: ''
  state_dir: ''
  to_email_address: ''
  from_email_address: ''
  reply_to_email_address: ''
  html_email: ''
  group_pull_request_updates: ''
  alert_on_close: false
  opened_subject: ''
jhelwig/Ruby-GitHub-Pull-Request-Bot: {}
        HERE

        lambda { PullRequestBot.new }.should_not raise_error
      end

      it 'should require a repository section' do
        write_config <<-HERE
---
default:
  template_dir: ''
  state_dir: ''
  to_email_address: ''
  from_email_address: ''
  reply_to_email_address: ''
  html_email: ''
  group_pull_request_updates: ''
  alert_on_close: false
  opened_subject: ''
        HERE
        lambda { PullRequestBot.new }.should raise_error(
          ArgumentError, /There must be at least one repository configured/
        )
      end

      it "should require a repository section of the form 'user-name/repository-name'" do
        write_config <<-HERE
---
default:
  template_dir: ''
  state_dir: ''
  to_email_address: ''
  from_email_address: ''
  reply_to_email_address: ''
  html_email: ''
  group_pull_request_updates: ''
  alert_on_close: false
  opened_subject: ''
not-a-valid-repository-section: {}
        HERE
        lambda { PullRequestBot.new }.should raise_error(
          ArgumentError, /Repositories must be of the form 'user-name\/repository-name': not-a-valid-repository-section/
        )
      end
    end

    describe 'repository settings' do
      it 'should inherit from the default section' do
        write_config <<-HERE
---
default:
  template_dir: './this-is-the-template-dir'
  state_dir: './this-is-the-state-dir'
  to_email_address: 'noreply+to-address@technosorcery.net'
  from_email_address: 'noreply+from-address@technosorcery.net'
  reply_to_email_address: 'noreply+reply-to-address@technosorcery.net'
  html_email: true
  group_pull_request_updates: true
  alert_on_close: false
  opened_subject: 'New pull requests'
jhelwig/Ruby-GitHub-Pull-Request-Bot: {}
        HERE

        bot = PullRequestBot.new
        bot.repositories['jhelwig/Ruby-GitHub-Pull-Request-Bot']['template_dir'].should == './this-is-the-template-dir'
      end

      it 'should be individually overrideable' do
        write_config <<-HERE
---
default:
  template_dir: './this-is-the-template-dir'
  state_dir: './this-is-the-state-dir'
  to_email_address: 'noreply+to-address@technosorcery.net'
  from_email_address: 'noreply+from-address@technosorcery.net'
  reply_to_email_address: 'noreply+reply-to-address@technosorcery.net'
  html_email: true
  group_pull_request_updates: true
  alert_on_close: false
  opened_subject: 'New pull requests'
jhelwig/Ruby-GitHub-Pull-Request-Bot:
  template_dir: './this-is-the-overridden-template-dir'
        HERE

        bot = PullRequestBot.new
        bot.repositories['jhelwig/Ruby-GitHub-Pull-Request-Bot']['template_dir'].should == './this-is-the-overridden-template-dir'
        bot.repositories['jhelwig/Ruby-GitHub-Pull-Request-Bot']['state_dir'].should == './this-is-the-state-dir'
      end
    end
  end

  def write_config(contents)
    File.open(@config_file, 'w') {|f| f.write contents}
  end
end
