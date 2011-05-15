#!/usr/bin/env ruby

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
        write_config YAML.dump({
          'default' => {
            'state_dir'                  => '',
            'to_email_address'           => '',
            'from_email_address'         => '',
            'reply_to_email_address'     => '',
            'html_email'                 => '',
            'group_pull_request_updates' => '',
            'alert_on_close'             => '',
            'opened_subject'             => '',
            'closed_subject'             => ''
          }
        })

        lambda { PullRequestBot.new }.should raise_error(
          ArgumentError, /'default' section must contain 'template_dir'/
        )
      end

      it 'should require a default state_dir' do
        write_config YAML.dump({
          'default' => {
            'template_dir'               => '',
            'to_email_address'           => '',
            'from_email_address'         => '',
            'reply_to_email_address'     => '',
            'html_email'                 => '',
            'group_pull_request_updates' => '',
            'alert_on_close'             => '',
            'opened_subject'             => '',
            'closed_subject'             => ''
          }
        })

        lambda { PullRequestBot.new }.should raise_error(
          ArgumentError, /'default' section must contain 'state_dir'/
        )
      end

      it 'should require a default to_email_address' do
        write_config YAML.dump({
          'default' => {
            'template_dir'               => '',
            'state_dir'                  => '',
            'from_email_address'         => '',
            'reply_to_email_address'     => '',
            'html_email'                 => '',
            'group_pull_request_updates' => '',
            'alert_on_close'             => '',
            'opened_subject'             => '',
            'closed_subject'             => ''
          }
        })

        lambda { PullRequestBot.new }.should raise_error(
          ArgumentError, /'default' section must contain 'to_email_address'/
        )
      end

      it 'should require a default from_email_address' do
        write_config YAML.dump({
          'default' => {
            'template_dir'               => '',
            'state_dir'                  => '',
            'to_email_address'           => '',
            'reply_to_email_address'     => '',
            'html_email'                 => '',
            'group_pull_request_updates' => '',
            'alert_on_close'             => '',
            'opened_subject'             => '',
            'closed_subject'             => ''
          }
        })

        lambda { PullRequestBot.new }.should raise_error(
          ArgumentError, /'default' section must contain 'from_email_address'/
        )
      end

      it 'should require a default reply_to_email_address' do
        write_config YAML.dump({
          'default' => {
            'template_dir'               => '',
            'state_dir'                  => '',
            'to_email_address'           => '',
            'from_email_address'         => '',
            'html_email'                 => '',
            'group_pull_request_updates' => '',
            'alert_on_close'             => '',
            'opened_subject'             => '',
            'closed_subject'             => ''
          }
        })

        lambda { PullRequestBot.new }.should raise_error(
          ArgumentError, /'default' section must contain 'reply_to_email_address'/
        )
      end

      it 'should require a default html_email' do
        write_config YAML.dump({
          'default' => {
            'template_dir'               => '',
            'state_dir'                  => '',
            'to_email_address'           => '',
            'from_email_address'         => '',
            'reply_to_email_address'     => '',
            'group_pull_request_updates' => '',
            'alert_on_close'             => '',
            'opened_subject'             => '',
            'closed_subject'             => ''
          }
        })

        lambda { PullRequestBot.new }.should raise_error(
          ArgumentError, /'default' section must contain 'html_email'/
        )
      end

      it 'should require a default group_pull_request_updates' do
        write_config YAML.dump({
          'default' => {
            'template_dir'               => '',
            'state_dir'                  => '',
            'to_email_address'           => '',
            'from_email_address'         => '',
            'reply_to_email_address'     => '',
            'html_email'                 => '',
            'alert_on_close'             => '',
            'opened_subject'             => '',
            'closed_subject'             => ''
          }
        })

        lambda { PullRequestBot.new }.should raise_error(
          ArgumentError, /'default' section must contain 'group_pull_request_updates'/
        )
      end

      it 'should require a default alert_on_close' do
        write_config YAML.dump({
          'default' => {
            'template_dir'               => '',
            'state_dir'                  => '',
            'to_email_address'           => '',
            'from_email_address'         => '',
            'reply_to_email_address'     => '',
            'html_email'                 => '',
            'group_pull_request_updates' => '',
            'opened_subject'             => '',
            'closed_subject'             => ''
          }
        })

        lambda { PullRequestBot.new }.should raise_error(
          ArgumentError, /'default' section must contain 'alert_on_close'/
        )
      end

      it 'should require a default opened_subject' do
        write_config YAML.dump({
          'default' => {
            'template_dir'               => '',
            'state_dir'                  => '',
            'to_email_address'           => '',
            'from_email_address'         => '',
            'reply_to_email_address'     => '',
            'html_email'                 => '',
            'group_pull_request_updates' => '',
            'alert_on_close'             => '',
            'closed_subject'             => ''
          }
        })

        lambda { PullRequestBot.new }.should raise_error(
          ArgumentError, /'default' section must contain 'opened_subject'/
        )
      end

      it 'should require a default closed_subject when alert_on_close is true' do
        write_config YAML.dump({
          'default' => {
            'template_dir'               => '',
            'state_dir'                  => '',
            'to_email_address'           => '',
            'from_email_address'         => '',
            'reply_to_email_address'     => '',
            'html_email'                 => '',
            'group_pull_request_updates' => '',
            'alert_on_close'             => true,
            'opened_subject'             => '',
          }
        })

        lambda { PullRequestBot.new }.should raise_error(
          ArgumentError, /'default' section must contain 'closed_subject'/
        )
      end

      it 'should not require a default closed_subject when alert_on_close is false' do
        write_config YAML.dump({
          'default' => {
            'template_dir'               => '',
            'state_dir'                  => '',
            'to_email_address'           => '',
            'from_email_address'         => '',
            'reply_to_email_address'     => '',
            'html_email'                 => '',
            'group_pull_request_updates' => '',
            'alert_on_close'             => false,
            'opened_subject'             => '',
          },
          'jhelwig/Ruby-GitHub-Pull-Request-Bot' =>  {}
        })

        lambda { PullRequestBot.new }.should_not raise_error
      end

      it 'should require a repository section' do
        write_config YAML.dump({
          'default' => {
            'template_dir'               => '',
            'state_dir'                  => '',
            'to_email_address'           => '',
            'from_email_address'         => '',
            'reply_to_email_address'     => '',
            'html_email'                 => '',
            'group_pull_request_updates' => '',
            'alert_on_close'             => false,
            'opened_subject'             => '',
          },
        })

        lambda { PullRequestBot.new }.should raise_error(
          ArgumentError, /There must be at least one repository configured/
        )
      end

      it "should require a repository section of the form 'user-name/repository-name'" do
        write_config YAML.dump({
          'default' => {
            'template_dir'               => '',
            'state_dir'                  => '',
            'to_email_address'           => '',
            'from_email_address'         => '',
            'reply_to_email_address'     => '',
            'html_email'                 => '',
            'group_pull_request_updates' => '',
            'alert_on_close'             => false,
            'opened_subject'             => '',
          },
          'not-a-valid-repository-section' =>  {}
        })

        lambda { PullRequestBot.new }.should raise_error(
          ArgumentError,
          /Repositories must be of the form 'user-name\/repository-name': not-a-valid-repository-section/
        )
      end
    end

    describe 'repository settings' do
      it 'should inherit from the default section' do
        write_config YAML.dump({
          'default' => {
            'template_dir'               => './this-is-the-template-dir',
            'state_dir'                  => './this-is-the-state-dir',
            'to_email_address'           => 'noreply+to-address@technosorcery.net',
            'from_email_address'         => 'noreply+from-address@technosorcery.net',
            'reply_to_email_address'     => 'noreply+reply-to-address@technosorcery.net',
            'html_email'                 => true,
            'group_pull_request_updates' => false,
            'alert_on_close'             => false,
            'opened_subject'             => 'New pull requests',
          },
          'jhelwig/Ruby-GitHub-Pull-Request-Bot' => {}
        })

        bot = PullRequestBot.new
        bot.repositories['jhelwig/Ruby-GitHub-Pull-Request-Bot']['template_dir'].
          should == './this-is-the-template-dir'
      end

      it 'should be individually overrideable' do
        write_config YAML.dump({
          'default' => {
            'template_dir'               => './this-is-the-template-dir',
            'state_dir'                  => './this-is-the-state-dir',
            'to_email_address'           => 'noreply+to-address@technosorcery.net',
            'from_email_address'         => 'noreply+from-address@technosorcery.net',
            'reply_to_email_address'     => 'noreply+reply-to-address@technosorcery.net',
            'html_email'                 => true,
            'group_pull_request_updates' => false,
            'alert_on_close'             => false,
            'opened_subject'             => 'New pull requests',
          },
          'jhelwig/Ruby-GitHub-Pull-Request-Bot' => {
            'template_dir' => './this-is-the-overridden-template-dir'
          }
        })

        bot = PullRequestBot.new
        bot.repositories['jhelwig/Ruby-GitHub-Pull-Request-Bot']['template_dir'].
          should == './this-is-the-overridden-template-dir'
        bot.repositories['jhelwig/Ruby-GitHub-Pull-Request-Bot']['state_dir'].
          should == './this-is-the-state-dir'
      end
    end

    describe '#run' do
      describe 'with a single configured repository' do
        before :each do
          @template_dir = File.join @config_dir, 'templates'
          populate_template_dir(@template_dir, 'text')
          write_config YAML.dump({
            'default' => {
              'template_dir'               => @template_dir,
              'state_dir'                  => './this-is-the-state-dir',
              'to_email_address'           => 'noreply+to-address@technosorcery.net',
              'from_email_address'         => 'noreply+from-address@technosorcery.net',
              'reply_to_email_address'     => 'noreply+reply-to-address@technosorcery.net',
              'html_email'                 => false,
              'group_pull_request_updates' => false,
              'alert_on_close'             => false,
              'opened_subject'             => 'New pull request: {{title}}',
            },
            'jhelwig/Ruby-GitHub-Pull-Request-Bot' => {}
          })

          @bot = PullRequestBot.new
        end

        it 'should request the list of open pull requests for the configured repository' do
          PullRequestBot.expects(:get).
            with('/pulls/jhelwig/Ruby-GitHub-Pull-Request-Bot/open').returns({})

          @bot.run
        end

        describe 'with no open pull requests' do
          it 'should not send any mail' do
            PullRequestBot.stubs(:get).returns({})
            Pony.expects(:mail).never

            @bot.run
          end
        end

        describe 'with a single open pull request' do
          describe 'configured to send plain-text messages' do
            before :each do
              PullRequestBot.stubs(:get).returns(
                JSON.parse(read_fixture('json/single_repo_single_open_pull_request.json'))
              )
            end

            it 'should send a single message' do
              Pony.expects(:mail).once.with(
                :to      => 'noreply+to-address@technosorcery.net',
                :from    => 'noreply+from-address@technosorcery.net',
                :headers => { 'Reply-To' => 'noreply+reply-to-address@technosorcery.net' },
                :body    => read_fixture('json/single_repo_single_open_pull_request/individual/body.txt'),
                :subject => 'New pull request: Add Bundler, move from tabs to ruby convetion of 2 spaces and add reply_to option'
              ).returns nil

              @bot.run
            end
          end
        end

        describe 'with multiple open pull requests' do
          before :each do
            PullRequestBot.stubs(:get).returns(
              JSON.parse(read_fixture('json/single_repo_multiple_open_pull_requests.json'))
            )
          end

          describe "configured to send plain-text messages" do
            it 'should send one message per open pull request' do
              Pony.expects(:mail).once.with(
                :to      => 'noreply+to-address@technosorcery.net',
                :from    => 'noreply+from-address@technosorcery.net',
                :headers => { 'Reply-To' => 'noreply+reply-to-address@technosorcery.net' },
                :body    => read_fixture('json/single_repo_multiple_open_pull_requests/individual/pull_eight_body.txt'),
                :subject => 'New pull request: Please pull virtualbox support for the virtual fact'
              ).returns nil
              Pony.expects(:mail).once.with(
                :to      => 'noreply+to-address@technosorcery.net',
                :from    => 'noreply+from-address@technosorcery.net',
                :headers => { 'Reply-To' => 'noreply+reply-to-address@technosorcery.net' },
                :body    => read_fixture('json/single_repo_multiple_open_pull_requests/individual/pull_six_body.txt'),
                :subject => 'New pull request: Ruby 1.9 fixes.'
              ).returns nil

              @bot.run
            end
          end
        end
      end

      describe 'with multiple configured repositories' do
        before :each do
          @template_dir = File.join(@config_dir, 'templates')
          populate_template_dir(@template_dir, 'text')

          write_config YAML.dump({
            'default' => {
              'template_dir'               => @template_dir,
              'state_dir'                  => './this-is-the-state-dir',
              'to_email_address'           => 'noreply+to-address@technosorcery.net',
              'from_email_address'         => 'noreply+from-address@technosorcery.net',
              'reply_to_email_address'     => 'noreply+reply-to-address@technosorcery.net',
              'html_email'                 => false,
              'group_pull_request_updates' => false,
              'alert_on_close'             => false,
              'opened_subject'             => 'New pull request: {{title}}',
            },
            'jhelwig/Ruby-GitHub-Pull-Request-Bot' => { },
            'jhelwig/technosorcery.net'            => { }
          })

          @bot = PullRequestBot.new
        end

        it 'should request the list of open pull requests for each configured repository' do
          PullRequestBot.expects(:get).
            with('/pulls/jhelwig/Ruby-GitHub-Pull-Request-Bot/open').returns({})
          PullRequestBot.expects(:get).
            with('/pulls/jhelwig/technosorcery.net/open').returns({})

          @bot.run
        end

        describe 'with no open pull requests' do
          it 'should not send any mail' do
            PullRequestBot.stubs(:get).returns({})
            Pony.expects(:mail).never

            @bot.run
          end
        end

        describe 'with a single open pull request' do
          describe 'configured to send plain-text messages' do
            before :each do
              PullRequestBot.expects(:get).
                with('/pulls/jhelwig/Ruby-GitHub-Pull-Request-Bot/open').
                returns(JSON.parse(read_fixture('json/first_repo_single_open_pull_request.json')))
              PullRequestBot.expects(:get).
                with('/pulls/jhelwig/technosorcery.net/open').
                returns(JSON.parse(read_fixture('json/second_repo_single_open_pull_request.json')))
            end

            it 'should send a single message per repository' do
              Pony.expects(:mail).once.with(
                :to      => 'noreply+to-address@technosorcery.net',
                :from    => 'noreply+from-address@technosorcery.net',
                :headers => { 'Reply-To' => 'noreply+reply-to-address@technosorcery.net' },
                :body    => read_fixture('json/first_repo_single_open_pull_request/individual/body.txt'),
                :subject => 'New pull request: Second pull request'
              ).returns nil
              Pony.expects(:mail).once.with(
                :to      => 'noreply+to-address@technosorcery.net',
                :from    => 'noreply+from-address@technosorcery.net',
                :headers => { 'Reply-To' => 'noreply+reply-to-address@technosorcery.net' },
                :body    => read_fixture('json/second_repo_single_open_pull_request/individual/body.txt'),
                :subject => 'New pull request: Add Bundler, move from tabs to ruby convetion of 2 spaces and add reply_to option'
              ).returns nil

              @bot.run
            end
          end
        end

        describe 'with multiple open pull requests' do
          before :each do
            PullRequestBot.expects(:get).
              with('/pulls/jhelwig/Ruby-GitHub-Pull-Request-Bot/open').
              returns(JSON.parse(read_fixture('json/first_repo_multiple_open_pull_requests.json')))
            PullRequestBot.expects(:get).
              with('/pulls/jhelwig/technosorcery.net/open').
              returns(JSON.parse(read_fixture('json/second_repo_multiple_open_pull_requests.json')))
          end

          describe "configured to send plain-text messages" do
            it 'should send one message per open pull request' do
              Pony.expects(:mail).once.with(
                :to      => 'noreply+to-address@technosorcery.net',
                :from    => 'noreply+from-address@technosorcery.net',
                :headers => { 'Reply-To' => 'noreply+reply-to-address@technosorcery.net' },
                :body    => read_fixture('json/first_repo_multiple_open_pull_requests/individual/pull_eight_body.txt'),
                :subject => 'New pull request: Please pull virtualbox support for the virtual fact'
              ).returns nil
              Pony.expects(:mail).once.with(
                :to      => 'noreply+to-address@technosorcery.net',
                :from    => 'noreply+from-address@technosorcery.net',
                :headers => { 'Reply-To' => 'noreply+reply-to-address@technosorcery.net' },
                :body    => read_fixture('json/first_repo_multiple_open_pull_requests/individual/pull_six_body.txt'),
                :subject => 'New pull request: Ruby 1.9 fixes.'
              ).returns nil
              Pony.expects(:mail).once.with(
                :to      => 'noreply+to-address@technosorcery.net',
                :from    => 'noreply+from-address@technosorcery.net',
                :headers => { 'Reply-To' => 'noreply+reply-to-address@technosorcery.net' },
                :body    => read_fixture('json/second_repo_multiple_open_pull_requests/individual/pull_eight_body.txt'),
                :subject => 'New pull request: Repo 2 Pull 8'
              ).returns nil
              Pony.expects(:mail).once.with(
                :to      => 'noreply+to-address@technosorcery.net',
                :from    => 'noreply+from-address@technosorcery.net',
                :headers => { 'Reply-To' => 'noreply+reply-to-address@technosorcery.net' },
                :body    => read_fixture('json/second_repo_multiple_open_pull_requests/individual/pull_six_body.txt'),
                :subject => 'New pull request: Repo 2 Pull 6'
              ).returns nil

              @bot.run
            end
          end
        end
      end
    end

    describe 'templating' do
      it 'should support template snippits relative to the template_dir setting' do
        @template_dir = File.join(@config_dir, 'templates')
        populate_template_dir(@template_dir, 'with_snippits')

        write_config YAML.dump({
            'default' => {
              'template_dir'               => @template_dir,
              'state_dir'                  => './this-is-the-state-dir',
              'to_email_address'           => 'noreply+to-address@technosorcery.net',
              'from_email_address'         => 'noreply+from-address@technosorcery.net',
              'reply_to_email_address'     => 'noreply+reply-to-address@technosorcery.net',
              'html_email'                 => false,
              'group_pull_request_updates' => false,
              'alert_on_close'             => false,
              'opened_subject'             => 'New pull request: {{title}}',
            },
            'jhelwig/Ruby-GitHub-Pull-Request-Bot' => {}
        })

        PullRequestBot.stubs(:get).returns(
          JSON.parse(read_fixture('json/single_repo_single_open_pull_request.json'))
        )

        Pony.expects(:mail).once.with(
          :to      => 'noreply+to-address@technosorcery.net',
          :from    => 'noreply+from-address@technosorcery.net',
          :headers => { 'Reply-To' => 'noreply+reply-to-address@technosorcery.net' },
          :body    => read_fixture('json/single_repo_single_open_pull_request/individual-snippit/body.txt'),
          :subject => 'New pull request: Add Bundler, move from tabs to ruby convetion of 2 spaces and add reply_to option'
        ).returns nil

        PullRequestBot.new.run
      end

      it 'should support sending email with HTML body' do
        @template_dir = File.join(@config_dir, 'templates')
        populate_template_dir(@template_dir, 'html')

        write_config YAML.dump({
            'default' => {
              'template_dir'               => @template_dir,
              'state_dir'                  => './this-is-the-state-dir',
              'to_email_address'           => 'noreply+to-address@technosorcery.net',
              'from_email_address'         => 'noreply+from-address@technosorcery.net',
              'reply_to_email_address'     => 'noreply+reply-to-address@technosorcery.net',
              'html_email'                 => true,
              'group_pull_request_updates' => false,
              'alert_on_close'             => false,
              'opened_subject'             => 'New pull request: {{title}}',
            },
            'jhelwig/Ruby-GitHub-Pull-Request-Bot' => {}
        })

        PullRequestBot.stubs(:get).returns(
          JSON.parse(read_fixture('json/single_repo_single_open_pull_request.json'))
        )

        Pony.expects(:mail).once.with(
          :to        => 'noreply+to-address@technosorcery.net',
          :from      => 'noreply+from-address@technosorcery.net',
          :headers   => { 'Reply-To' => 'noreply+reply-to-address@technosorcery.net' },
          :html_body => read_fixture('json/single_repo_single_open_pull_request/individual/body.html'),
          :subject   => 'New pull request: Add Bundler, move from tabs to ruby convetion of 2 spaces and add reply_to option'
        ).returns nil

        PullRequestBot.new.run
      end

      it 'should support sending email with text body' do
        @template_dir = File.join(@config_dir, 'templates')
        populate_template_dir(@template_dir, 'text')

        write_config YAML.dump({
            'default' => {
              'template_dir'               => @template_dir,
              'state_dir'                  => './this-is-the-state-dir',
              'to_email_address'           => 'noreply+to-address@technosorcery.net',
              'from_email_address'         => 'noreply+from-address@technosorcery.net',
              'reply_to_email_address'     => 'noreply+reply-to-address@technosorcery.net',
              'html_email'                 => false,
              'group_pull_request_updates' => false,
              'alert_on_close'             => false,
              'opened_subject'             => 'New pull request: {{title}}',
            },
            'jhelwig/Ruby-GitHub-Pull-Request-Bot' => {}
        })

        PullRequestBot.stubs(:get).returns(
          JSON.parse(read_fixture('json/single_repo_single_open_pull_request.json'))
        )

        Pony.expects(:mail).once.with(
          :to      => 'noreply+to-address@technosorcery.net',
          :from    => 'noreply+from-address@technosorcery.net',
          :headers => { 'Reply-To' => 'noreply+reply-to-address@technosorcery.net' },
          :body    => read_fixture('json/single_repo_single_open_pull_request/individual/body.txt'),
          :subject => 'New pull request: Add Bundler, move from tabs to ruby convetion of 2 spaces and add reply_to option'
        ).returns nil

        PullRequestBot.new.run
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
