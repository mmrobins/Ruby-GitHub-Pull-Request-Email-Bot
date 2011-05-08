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
  opened_subject: 'New pull request: {{title}}'
jhelwig/Ruby-GitHub-Pull-Request-Bot:
  template_dir: './this-is-the-overridden-template-dir'
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
              JSON.parse %q({"pulls":[{"base":{"label":"benprew:master","repository":{"homepage":"","has_issues":false,"url":"https://github.com/benprew/pony","has_downloads":true,"fork":true,"created_at":"2009/07/27 15:46:36 -0700","pushed_at":"2011/04/20 10:54:17 -0700","forks":17,"description":"The express way to send mail from Ruby.","size":200,"private":false,"name":"pony","watchers":333,"owner":"benprew","has_wiki":true,"language":"Ruby","open_issues":1},"sha":"e5f5f1ea3ebac5e2db5ba7b45bdc2c5b9c4ea9ad","user":{"name":"Ben Prew","company":"","gravatar_id":"c435128d516e3cd2b8fa27ae41c18b93","location":"Portland, OR","blog":"http://verastreet.com","type":"User","login":"benprew","email":"ben.prew@gmail.com"},"ref":"master"},"issue_updated_at":"2011-03-25T11:50:10Z","gravatar_id":"89e57a28dfdb85e07b33f92783dbe349","position":1.0,"number":2,"votes":0,"html_url":"https://github.com/benprew/pony/pull/2","comments":1,"body":"Hello, thanks for the Gem, it's awesome.\r\n\r\nI did a quick commit moving the code to Bundler. So I was able to do a bundle install and run the specs without the need of manual installations. I also added Rspec as a development dependency.\r\n\r\nI also moved most of the files from tabs to softabs (2 spaces) which is the convention for Ruby files. In this way we avoid issues with diferent identations depending of which Text Editor/ IDE you are using.\r\n\r\nMy last contribution is a reply_to option that Mail supports but Pony not. It's importanto for contact forms because the user that will receive the email could quickly reply who sended the message.\r\n\r\nThanks.","title":"Add Bundler, move from tabs to ruby convetion of 2 spaces and add reply_to option","diff_url":"https://github.com/benprew/pony/pull/2.diff","head":{"label":"danielvlopes:master","repository":{"homepage":"","has_issues":false,"url":"https://github.com/danielvlopes/pony","has_downloads":true,"fork":true,"created_at":"2011/03/22 20:54:51 -0700","pushed_at":"2011/03/22 20:57:41 -0700","forks":1,"description":"The express way to send mail from Ruby.","size":172,"private":false,"name":"pony","watchers":2,"owner":"danielvlopes","has_wiki":true,"language":"Ruby","open_issues":0},"sha":"562c2072ec478dbf540ffa3b577243be82e53235","user":{"name":"Daniel Lopes","company":"Area Criações","gravatar_id":"89e57a28dfdb85e07b33f92783dbe349","location":"Belo Horizonte - MG - Brasil","blog":"blog.areacriacoes.com.br","type":"User","login":"danielvlopes","email":"danielvlopes@areacriacoes.com.br"},"ref":"master"},"issue_user":{"name":"Daniel Lopes","company":"Area Criações","gravatar_id":"89e57a28dfdb85e07b33f92783dbe349","location":"Belo Horizonte - MG - Brasil","blog":"blog.areacriacoes.com.br","type":"User","login":"danielvlopes","email":"danielvlopes@areacriacoes.com.br"},"updated_at":"2011-03-23T04:13:59Z","created_at":"2011-03-23T04:13:59Z","patch_url":"https://github.com/benprew/pony/pull/2.patch","user":{"name":"Daniel Lopes","company":"Area Criações","gravatar_id":"89e57a28dfdb85e07b33f92783dbe349","location":"Belo Horizonte - MG - Brasil","blog":"blog.areacriacoes.com.br","type":"User","login":"danielvlopes","email":"danielvlopes@areacriacoes.com.br"},"issue_created_at":"2011-03-23T04:13:59Z","labels":[],"mergeable":null,"state":"open"}]})
            )
          end

          it 'should send a single message' do
            Pony.expects(:mail).once.with(
              :to        => 'noreply+to-address@technosorcery.net',
              :from      => 'noreply+from-address@technosorcery.net',
              :headers   => { 'Reply-To' => 'noreply+reply-to-address@technosorcery.net' },
              :html_body => 'https://github.com/benprew/pony/pull/2',
              :subject   => 'New pull request: Add Bundler, move from tabs to ruby convetion of 2 spaces and add reply_to option'
            ).returns nil

            @bot.run
          end
        end

        describe 'with multiple open pull requests' do
          before :each do
            PullRequestBot.any_instance.stubs(:get).returns(
              JSON.parse %q({"pulls":[{"base":{"label":"puppetlabs:master","repository":{"homepage":"http://projects.puppetlabs.com/projects/facter","has_wiki":true,"open_issues":2,"url":"https://github.com/puppetlabs/facter","has_issues":false,"fork":false,"created_at":"2010/09/14 12:31:04 -0700","integrate_branch":"testing","organization":"puppetlabs","description":"","size":3092,"private":false,"name":"facter","watchers":74,"owner":"puppetlabs","has_downloads":true,"language":"Ruby","pushed_at":"2011/05/03 20:14:15 -0700","forks":72},"sha":"cfcc4285e2e505700e16142deb10f58523a05f08","user":{"name":"Puppet Labs","gravatar_id":"eb454c2139c156db7c8266a875519a1f","location":"Portland, OR","blog":"http://www.puppetlabs.com/","type":"Organization","login":"puppetlabs","email":"info@puppetlabs.com"},"ref":"master"},"issue_updated_at":"2011-04-20T10:58:36Z","gravatar_id":"d613eb55045129088f573ac74722b8f8","position":5.0,"number":8,"votes":0,"comments":0,"body":"I added virtualbox support in the virtual fact for lspci and dmidecode\r\nIt works, provided (on my system) that you are root when  running facter due to the permissions on lspci and dmidecode","title":"Please pull virtualbox support for the virtual fact","mergeable":true,"diff_url":"https://github.com/puppetlabs/facter/pull/8.diff","head":{"label":"ramonvanalteren:master","repository":{"homepage":"http://projects.puppetlabs.com/projects/facter","has_wiki":true,"open_issues":0,"url":"https://github.com/ramonvanalteren/facter","has_issues":false,"fork":true,"created_at":"2011/04/20 01:39:47 -0700","integrate_branch":"testing","description":"","size":2968,"private":false,"name":"facter","watchers":1,"owner":"ramonvanalteren","has_downloads":true,"language":"Ruby","pushed_at":"2011/04/20 01:43:39 -0700","forks":0},"sha":"447fb980e1d28917b43100bdc1e8331dbc48c25d","user":{"name":"Ramon van Alteren","company":"Hyves","gravatar_id":"d613eb55045129088f573ac74722b8f8","location":"Amsterdam","blog":"ramon71.hyves.nl","type":"User","login":"ramonvanalteren","email":"noreply+ramon_hyves.nl@technosorcery.net"},"ref":"master"},"updated_at":"2011-04-29T21:17:33Z","created_at":"2011-04-20T10:58:36Z","patch_url":"https://github.com/puppetlabs/facter/pull/8.patch","html_url":"https://github.com/puppetlabs/facter/pull/8","user":{"name":"Ramon van Alteren","company":"Hyves","gravatar_id":"d613eb55045129088f573ac74722b8f8","location":"Amsterdam","blog":"ramon71.hyves.nl","type":"User","login":"ramonvanalteren","email":"noreply+ramon_hyves.nl@technosorcery.net"},"issue_created_at":"2011-04-20T10:58:36Z","labels":[],"issue_user":{"name":"Ramon van Alteren","company":"Hyves","gravatar_id":"d613eb55045129088f573ac74722b8f8","location":"Amsterdam","blog":"ramon71.hyves.nl","type":"User","login":"ramonvanalteren","email":"noreply+ramon_hyves.nl@technosorcery.net"},"state":"open"},{"base":{"label":"puppetlabs:next","repository":{"homepage":"http://projects.puppetlabs.com/projects/facter","has_wiki":true,"open_issues":2,"url":"https://github.com/puppetlabs/facter","has_issues":false,"fork":false,"created_at":"2010/09/14 12:31:04 -0700","integrate_branch":"testing","organization":"puppetlabs","description":"","size":3092,"private":false,"name":"facter","watchers":74,"owner":"puppetlabs","has_downloads":true,"language":"Ruby","pushed_at":"2011/05/03 20:14:15 -0700","forks":72},"sha":"6e02daa1ed56f9758226f4e640ec419395868728","user":{"name":"Puppet Labs","gravatar_id":"eb454c2139c156db7c8266a875519a1f","location":"Portland, OR","blog":"http://www.puppetlabs.com/","type":"Organization","login":"puppetlabs","email":"info@puppetlabs.com"},"ref":"next"},"issue_updated_at":"2011-04-12T23:43:48Z","gravatar_id":"4605adbcd13e20c14e82fcf528b516e6","position":1.0,"number":6,"votes":0,"comments":0,"body":"Ticket: https://projects.puppetlabs.com/issues/6614","title":"Ruby 1.9 fixes.","mergeable":null,"diff_url":"https://github.com/puppetlabs/facter/pull/6.diff","head":{"label":"malditogeek:ticket/next/6614","repository":{"homepage":"http://projects.puppetlabs.com/projects/facter","has_wiki":true,"open_issues":0,"url":"https://github.com/malditogeek/facter","has_issues":false,"fork":true,"created_at":"2011/04/12 14:27:36 -0700","integrate_branch":"testing","description":"","size":2952,"private":false,"name":"facter","watchers":1,"owner":"malditogeek","has_downloads":true,"language":"Ruby","pushed_at":"2011/04/12 16:09:48 -0700","forks":0},"sha":"1eb3667142d2f56ad5436d91c457a776c52dd3c7","user":{"name":"Mauro Pompilio","company":"http://forward.co.uk","gravatar_id":"4605adbcd13e20c14e82fcf528b516e6","location":"London, UK","blog":"","type":"User","login":"malditogeek","email":"noreply+hackers.are.rockstars_gmail.com@technosorcery.net"},"ref":"ticket/next/6614"},"updated_at":"2011-04-12T23:43:48Z","created_at":"2011-04-12T23:43:48Z","patch_url":"https://github.com/puppetlabs/facter/pull/6.patch","html_url":"https://github.com/puppetlabs/facter/pull/6","user":{"name":"Mauro Pompilio","company":"http://forward.co.uk","gravatar_id":"4605adbcd13e20c14e82fcf528b516e6","location":"London, UK","blog":"","type":"User","login":"malditogeek","email":"noreply+hackers.are.rockstars_gmail.com@technosorcery.net"},"issue_created_at":"2011-04-12T23:43:48Z","labels":[],"issue_user":{"name":"Mauro Pompilio","company":"http://forward.co.uk","gravatar_id":"4605adbcd13e20c14e82fcf528b516e6","location":"London, UK","blog":"","type":"User","login":"malditogeek","email":"noreply+hackers.are.rockstars_gmail.com@technosorcery.net"},"state":"open"}]})
            )
          end
          it 'should send one message per open pull request' do
            Pony.expects(:mail).once.with(
              :to        => 'noreply+to-address@technosorcery.net',
              :from      => 'noreply+from-address@technosorcery.net',
              :headers   => { 'Reply-To' => 'noreply+reply-to-address@technosorcery.net' },
              :html_body => 'https://github.com/puppetlabs/facter/pull/8',
              :subject   => 'New pull request: Please pull virtualbox support for the virtual fact'
            ).returns nil
            Pony.expects(:mail).once.with(
              :to        => 'noreply+to-address@technosorcery.net',
              :from      => 'noreply+from-address@technosorcery.net',
              :headers   => { 'Reply-To' => 'noreply+reply-to-address@technosorcery.net' },
              :html_body => 'https://github.com/puppetlabs/facter/pull/6',
              :subject   => 'New pull request: Ruby 1.9 fixes.'
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
  html_email: true
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
