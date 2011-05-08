#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'spec_helper'

require 'json'

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
      @config_file = "config.yaml"
      ['-c', File.join(@config_dir, @config_file)].each {|x| ARGV.push x}
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
  group_pull_request_updates: false
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
  group_pull_request_updates: false
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

    describe '#run' do
      describe 'with a single configured repository' do
        before :each do
          @template_dir = File.join @config_dir, 'templates'
          write_config <<-HERE
---
default:
  template_dir: '#{@template_dir}'
  state_dir: './this-is-the-state-dir'
  to_email_address: 'noreply+to-address@technosorcery.net'
  from_email_address: 'noreply+from-address@technosorcery.net'
  reply_to_email_address: 'noreply+reply-to-address@technosorcery.net'
  html_email: false
  group_pull_request_updates: false
  alert_on_close: false
  opened_subject: 'New pull request: {{title}}'
jhelwig/Ruby-GitHub-Pull-Request-Bot: {}
          HERE

          write_file 'templates/individual_opened.mustache', <<-HERE
Please review the pull request #\{{number}}.

{{html_url}} was opened by {{#user}}{{name}} ({{login}}){{/user}}: {{title}}

Some more information about the pull request:
  Opened: {{created_at}}
  Merges cleanly: {{#mergeable}}Yes{{/mergeable}}{{^mergeable}}No{{/mergeable}}
  {{#base}}Based on: {{label}} ({{sha}}){{/base}}
  {{#head}}Requested merge: {{label}} ({{sha}}){{/head}}

Description:

{{body}}
          HERE

          @bot = PullRequestBot.new
        end

        it 'should request the list of open pull requests for the configured repository' do
          PullRequestBot.any_instance.expects(:get).with('/pulls/jhelwig/Ruby-GitHub-Pull-Request-Bot/open').returns({})

          @bot.run
        end

        describe 'with no open pull requests' do
          it 'should not send any mail' do
            PullRequestBot.any_instance.stubs(:get).returns({})
            Pony.expects(:mail).never

            @bot.run
          end
        end

        describe 'with a single open pull request' do
          before :each do
            PullRequestBot.any_instance.stubs(:get).returns(
              JSON.parse(read_fixture('json/single_repo_single_open_pull_request.json'))
            )
          end

          it 'should send a single message' do
            pull_two_body = <<-HERE
Please review the pull request #2.

https://github.com/benprew/pony/pull/2 was opened by Daniel Lopes (danielvlopes): Add Bundler, move from tabs to ruby convetion of 2 spaces and add reply_to option

Some more information about the pull request:
  Opened: 2011-03-23T04:13:59Z
  Merges cleanly: No
  Based on: benprew:master (e5f5f1ea3ebac5e2db5ba7b45bdc2c5b9c4ea9ad)
  Requested merge: danielvlopes:master (562c2072ec478dbf540ffa3b577243be82e53235)

Description:

Hello, thanks for the Gem, it's awesome.\r
\r
I did a quick commit moving the code to Bundler. So I was able to do a bundle install and run the specs without the need of manual installations. I also added Rspec as a development dependency.\r
\r
I also moved most of the files from tabs to softabs (2 spaces) which is the convention for Ruby files. In this way we avoid issues with diferent identations depending of which Text Editor/ IDE you are using.\r
\r
My last contribution is a reply_to option that Mail supports but Pony not. It's importanto for contact forms because the user that will receive the email could quickly reply who sended the message.\r
\r
Thanks.
            HERE
            Pony.expects(:mail).once.with(
              :to      => 'noreply+to-address@technosorcery.net',
              :from    => 'noreply+from-address@technosorcery.net',
              :headers => { 'Reply-To' => 'noreply+reply-to-address@technosorcery.net' },
              :body    => pull_two_body,
              :subject => 'New pull request: Add Bundler, move from tabs to ruby convetion of 2 spaces and add reply_to option'
            ).returns nil

            @bot.run
          end
        end

        describe 'with multiple open pull requests' do
          before :each do
            PullRequestBot.any_instance.stubs(:get).returns(
              JSON.parse(read_fixture('json/single_repo_multiple_open_pull_requests.json'))
            )
          end
          it 'should send one message per open pull request' do
            pull_eight_body = <<-HERE
Please review the pull request #8.

https://github.com/puppetlabs/facter/pull/8 was opened by Ramon van Alteren (ramonvanalteren): Please pull virtualbox support for the virtual fact

Some more information about the pull request:
  Opened: 2011-04-20T10:58:36Z
  Merges cleanly: Yes
  Based on: puppetlabs:master (cfcc4285e2e505700e16142deb10f58523a05f08)
  Requested merge: ramonvanalteren:master (447fb980e1d28917b43100bdc1e8331dbc48c25d)

Description:

I added virtualbox support in the virtual fact for lspci and dmidecode\r
It works, provided (on my system) that you are root when  running facter due to the permissions on lspci and dmidecode
            HERE
            pull_six_body = <<-HERE
Please review the pull request #6.

https://github.com/puppetlabs/facter/pull/6 was opened by Mauro Pompilio (malditogeek): Ruby 1.9 fixes.

Some more information about the pull request:
  Opened: 2011-04-12T23:43:48Z
  Merges cleanly: No
  Based on: puppetlabs:next (6e02daa1ed56f9758226f4e640ec419395868728)
  Requested merge: malditogeek:ticket/next/6614 (1eb3667142d2f56ad5436d91c457a776c52dd3c7)

Description:

Ticket: https://projects.puppetlabs.com/issues/6614
            HERE
            Pony.expects(:mail).once.with(
              :to      => 'noreply+to-address@technosorcery.net',
              :from    => 'noreply+from-address@technosorcery.net',
              :headers => { 'Reply-To' => 'noreply+reply-to-address@technosorcery.net' },
              :body    => pull_eight_body,
              :subject => 'New pull request: Please pull virtualbox support for the virtual fact'
            ).returns nil
            Pony.expects(:mail).once.with(
              :to      => 'noreply+to-address@technosorcery.net',
              :from    => 'noreply+from-address@technosorcery.net',
              :headers => { 'Reply-To' => 'noreply+reply-to-address@technosorcery.net' },
              :body    => pull_six_body,
              :subject => 'New pull request: Ruby 1.9 fixes.'
            ).returns nil

            @bot.run
          end
        end
      end

      describe 'with multiple configured repositories' do
        before :each do
          write_config <<-HERE
---
default:
  template_dir: './this-is-the-template-dir'
  state_dir: './this-is-the-state-dir'
  to_email_address: 'noreply+to-address@technosorcery.net'
  from_email_address: 'noreply+from-address@technosorcery.net'
  reply_to_email_address: 'noreply+reply-to-address@technosorcery.net'
  html_email: false
  group_pull_request_updates: false
  alert_on_close: false
  opened_subject: 'New pull requests'
jhelwig/Ruby-GitHub-Pull-Request-Bot:
  template_dir: './this-is-the-overridden-template-dir'
jhelwig/technosorcery.net:
  template_dir: './templates-technosorcery.net'
          HERE

          @bot = PullRequestBot.new
        end

        it 'should request the list of open pull requests for each configured repository' do
          PullRequestBot.any_instance.expects(:get).with('/pulls/jhelwig/Ruby-GitHub-Pull-Request-Bot/open').returns({})
          PullRequestBot.any_instance.expects(:get).with('/pulls/jhelwig/technosorcery.net/open').returns({})

          @bot.run
        end
      end
    end
  end

  def write_config(contents)
    write_file @config_file, contents
  end

  def write_file(path, contents)
    full_path = File.join @config_dir, path
    FileUtils.mkdir_p(File.dirname(full_path))
    File.open(full_path, 'w') {|f| f.write contents}
  end
end
