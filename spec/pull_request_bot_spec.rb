#!/usr/bin/env ruby

require 'spec_helper'

require 'json'
require 'octocat_herder/connection'
require 'octocat_herder/pull_request'

describe PullRequestBot do
  before :each do
    OctocatHerder::Connection.stubs(:get)
#    Pony.stubs(:mail)
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
        write_config({
          'default' => {
            'state_dir'                  => '',
            'to_email_address'           => '',
            'from_email_address'         => '',
            'reply_to_email_address'     => '',
            'html_email'                 => '',
            'group_pull_request_updates' => '',
            'alert_on_close'             => '',
            'open_subject'               => '',
            'closed_subject'             => ''
          }
        })

        lambda { PullRequestBot.new }.should raise_error(
          ArgumentError, /'default' section must contain 'template_dir'/
        )
      end

      it 'should require a default state_dir' do
        write_config({
          'default' => {
            'template_dir'               => '',
            'to_email_address'           => '',
            'from_email_address'         => '',
            'reply_to_email_address'     => '',
            'html_email'                 => '',
            'group_pull_request_updates' => '',
            'alert_on_close'             => '',
            'open_subject'               => '',
            'closed_subject'             => ''
          }
        })

        lambda { PullRequestBot.new }.should raise_error(
          ArgumentError, /'default' section must contain 'state_dir'/
        )
      end

      it 'should require a default to_email_address' do
        write_config({
          'default' => {
            'template_dir'               => '',
            'state_dir'                  => '',
            'from_email_address'         => '',
            'reply_to_email_address'     => '',
            'html_email'                 => '',
            'group_pull_request_updates' => '',
            'alert_on_close'             => '',
            'open_subject'               => '',
            'closed_subject'             => ''
          }
        })

        lambda { PullRequestBot.new }.should raise_error(
          ArgumentError, /'default' section must contain 'to_email_address'/
        )
      end

      it 'should require a default from_email_address' do
        write_config({
          'default' => {
            'template_dir'               => '',
            'state_dir'                  => '',
            'to_email_address'           => '',
            'reply_to_email_address'     => '',
            'html_email'                 => '',
            'group_pull_request_updates' => '',
            'alert_on_close'             => '',
            'open_subject'               => '',
            'closed_subject'             => ''
          }
        })

        lambda { PullRequestBot.new }.should raise_error(
          ArgumentError, /'default' section must contain 'from_email_address'/
        )
      end

      it 'should require a default reply_to_email_address' do
        write_config({
          'default' => {
            'template_dir'               => '',
            'state_dir'                  => '',
            'to_email_address'           => '',
            'from_email_address'         => '',
            'html_email'                 => '',
            'group_pull_request_updates' => '',
            'alert_on_close'             => '',
            'open_subject'               => '',
            'closed_subject'             => ''
          }
        })

        lambda { PullRequestBot.new }.should raise_error(
          ArgumentError, /'default' section must contain 'reply_to_email_address'/
        )
      end

      it 'should require a default html_email' do
        write_config({
          'default' => {
            'template_dir'               => '',
            'state_dir'                  => '',
            'to_email_address'           => '',
            'from_email_address'         => '',
            'reply_to_email_address'     => '',
            'group_pull_request_updates' => '',
            'alert_on_close'             => '',
            'open_subject'               => '',
            'closed_subject'             => ''
          }
        })

        lambda { PullRequestBot.new }.should raise_error(
          ArgumentError, /'default' section must contain 'html_email'/
        )
      end

      it 'should require a default group_pull_request_updates' do
        write_config({
          'default' => {
            'template_dir'               => '',
            'state_dir'                  => '',
            'to_email_address'           => '',
            'from_email_address'         => '',
            'reply_to_email_address'     => '',
            'html_email'                 => '',
            'alert_on_close'             => '',
            'open_subject'               => '',
            'closed_subject'             => ''
          }
        })

        lambda { PullRequestBot.new }.should raise_error(
          ArgumentError, /'default' section must contain 'group_pull_request_updates'/
        )
      end

      it 'should require a default alert_on_close' do
        write_config({
          'default' => {
            'template_dir'               => '',
            'state_dir'                  => '',
            'to_email_address'           => '',
            'from_email_address'         => '',
            'reply_to_email_address'     => '',
            'html_email'                 => '',
            'group_pull_request_updates' => '',
            'open_subject'               => '',
            'closed_subject'             => ''
          }
        })

        lambda { PullRequestBot.new }.should raise_error(
          ArgumentError, /'default' section must contain 'alert_on_close'/
        )
      end

      it 'should require a default open_subject' do
        write_config({
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
          ArgumentError, /'default' section must contain 'open_subject'/
        )
      end

      it 'should require a default closed_subject when alert_on_close is true' do
        write_config({
          'default' => {
            'template_dir'               => '',
            'state_dir'                  => '',
            'to_email_address'           => '',
            'from_email_address'         => '',
            'reply_to_email_address'     => '',
            'html_email'                 => '',
            'group_pull_request_updates' => '',
            'alert_on_close'             => true,
            'open_subject'               => '',
          }
        })

        lambda { PullRequestBot.new }.should raise_error(
          ArgumentError, /'default' section must contain 'closed_subject'/
        )
      end

      it 'should not require a default closed_subject when alert_on_close is false' do
        write_config({
          'default' => {
            'template_dir'               => '',
            'state_dir'                  => '',
            'to_email_address'           => '',
            'from_email_address'         => '',
            'reply_to_email_address'     => '',
            'html_email'                 => '',
            'group_pull_request_updates' => '',
            'alert_on_close'             => false,
            'open_subject'               => '',
          },
          'jhelwig/Ruby-GitHub-Pull-Request-Bot' =>  {}
        })

        lambda { PullRequestBot.new }.should_not raise_error
      end

      it 'should require a repository section' do
        write_config({
          'default' => {
            'template_dir'               => '',
            'state_dir'                  => '',
            'to_email_address'           => '',
            'from_email_address'         => '',
            'reply_to_email_address'     => '',
            'html_email'                 => '',
            'group_pull_request_updates' => '',
            'alert_on_close'             => false,
            'open_subject'               => '',
          },
        })

        lambda { PullRequestBot.new }.should raise_error(
          ArgumentError, /There must be at least one repository configured/
        )
      end

      it "should require a repository section to be in the form 'user-name/repository-name'" do
        invalid_repo_name = '@#$%^&invalid-user/invalid-repository#$%^'
        write_config({
          'default' => {
            'template_dir'               => '',
            'state_dir'                  => '',
            'to_email_address'           => '',
            'from_email_address'         => '',
            'reply_to_email_address'     => '',
            'html_email'                 => '',
            'group_pull_request_updates' => '',
            'alert_on_close'             => false,
            'open_subject'               => '',
          },
          invalid_repo_name =>  {}
        })

        lambda { PullRequestBot.new }.should raise_error(
          ArgumentError,
          "Repositories & users must be of the form '<user-name>/<repository-name>' or '<user-name>': #{invalid_repo_name}"
        )
      end

      it "should not allow more than one '/' in repository or user sections" do
        write_config({
          'default' => {
            'template_dir'               => '',
            'state_dir'                  => '',
            'to_email_address'           => '',
            'from_email_address'         => '',
            'reply_to_email_address'     => '',
            'html_email'                 => '',
            'group_pull_request_updates' => '',
            'alert_on_close'             => false,
            'open_subject'               => '',
          },
          'not/a/valid/repository/section' =>  {}
        })

        lambda { PullRequestBot.new }.should raise_error(
          ArgumentError,
          /Repositories & users must be of the form '<user-name>\/<repository-name>' or '<user-name>': not\/a\/valid\/repository\/section/
        )
      end

      it "should allow '.' in repository names" do
        write_config({
          'default' => {
            'template_dir'               => '',
            'state_dir'                  => '',
            'to_email_address'           => '',
            'from_email_address'         => '',
            'reply_to_email_address'     => '',
            'html_email'                 => '',
            'group_pull_request_updates' => '',
            'alert_on_close'             => false,
            'open_subject'               => '',
          },
          'jhelwig/technosorcery.net' =>  {}
        })

        lambda { PullRequestBot.new }.should_not raise_error
      end

      it "should specifying only the account owner" do
        write_config({
          'default' => {
            'template_dir'               => '',
            'state_dir'                  => '',
            'to_email_address'           => '',
            'from_email_address'         => '',
            'reply_to_email_address'     => '',
            'html_email'                 => '',
            'group_pull_request_updates' => '',
            'alert_on_close'             => false,
            'open_subject'               => '',
          },
          'jhelwig' =>  {}
        })

        lambda { PullRequestBot.new }.should_not raise_error
      end
    end

    describe 'repository settings' do
      it 'should inherit from the default section' do
        write_config({
          'default' => {
            'template_dir'               => './this-is-the-template-dir',
            'state_dir'                  => './this-is-the-state-dir',
            'to_email_address'           => 'noreply+to-address@technosorcery.net',
            'from_email_address'         => 'noreply+from-address@technosorcery.net',
            'reply_to_email_address'     => 'noreply+reply-to-address@technosorcery.net',
            'html_email'                 => true,
            'group_pull_request_updates' => false,
            'alert_on_close'             => false,
            'open_subject'               => 'New pull requests',
          },
          'jhelwig/Ruby-GitHub-Pull-Request-Bot' => {}
        })

        bot = PullRequestBot.new
        bot.repositories['jhelwig/Ruby-GitHub-Pull-Request-Bot']['template_dir'].
          should == './this-is-the-template-dir'
      end

      it 'should be individually overrideable' do
        write_config({
          'default' => {
            'template_dir'               => './this-is-the-template-dir',
            'state_dir'                  => './this-is-the-state-dir',
            'to_email_address'           => 'noreply+to-address@technosorcery.net',
            'from_email_address'         => 'noreply+from-address@technosorcery.net',
            'reply_to_email_address'     => 'noreply+reply-to-address@technosorcery.net',
            'html_email'                 => true,
            'group_pull_request_updates' => false,
            'alert_on_close'             => false,
            'open_subject'               => 'New pull requests',
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
          @state_dir = File.join @config_dir, 'state'
          populate_template_dir(@template_dir, 'text')
          write_config({
            'default' => {
              'template_dir'               => @template_dir,
              'state_dir'                  => @state_dir,
              'to_email_address'           => 'noreply+to-address@technosorcery.net',
              'from_email_address'         => 'noreply+from-address@technosorcery.net',
              'reply_to_email_address'     => 'noreply+reply-to-address@technosorcery.net',
              'html_email'                 => false,
              'group_pull_request_updates' => false,
              'alert_on_close'             => false,
              'open_subject'               => 'New pull request: {{title}}',
            },
            'jhelwig/Ruby-GitHub-Pull-Request-Bot' => {}
          })
        end

        it 'should request the list of open pull requests for the configured repository' do
          OctocatHerder::PullRequest.expects(:find_for_repository).with(
            'jhelwig',
            'Ruby-GitHub-Pull-Request-Bot',
            'open'
          )

          PullRequestBot.new.run
        end

        describe 'with no open pull requests' do
          it 'should not send any mail' do
            OctocatHerder::PullRequest.stubs(:find_for_repository)
            Pony.expects(:mail).never

            PullRequestBot.new.run
          end
        end

        describe 'with a single open pull request' do
          describe 'configured to send plain-text messages' do
            before :each do
              OctocatHerder::PullRequest.stubs(:find_for_repository).returns(
                [OctocatHerder::PullRequest.new(
                  nil,
                  JSON.parse(read_fixture('json/single_repo_single_open_pull_request.json'))
                )]
              )
            end

            it 'should send a single message' do
              Pony.expects(:mail).once.with(
                :to      => 'noreply+to-address@technosorcery.net',
                :from    => 'noreply+from-address@technosorcery.net',
                :headers => { 'Reply-To' => 'noreply+reply-to-address@technosorcery.net' },
                :body    => read_fixture('json/single_repo_single_open_pull_request/individual/body.txt'),
                :subject => 'New pull request: Resolve encoding errors in Ruby 1.9'
              ).returns nil

              PullRequestBot.new.run
            end
          end
        end

        describe 'with multiple open pull requests' do
          before :each do
            OctocatHerder::PullRequest.stubs(:find_for_repository).returns(
              JSON.parse(read_fixture('json/single_repo_multiple_open_pull_requests.json')).map do |req|
                OctocatHerder::PullRequest.new(nil, req)
              end
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

              PullRequestBot.new.run
            end
          end
        end
      end

      describe 'configured to notify on closed pull requests' do
        before :each do
          @template_dir = File.join @config_dir, 'templates'
          @state_dir = File.join @config_dir, 'state'
          populate_template_dir(@template_dir, 'text')
          write_config({
            'default' => {
              'template_dir'               => @template_dir,
              'state_dir'                  => @state_dir,
              'to_email_address'           => 'noreply+to-address@technosorcery.net',
              'from_email_address'         => 'noreply+from-address@technosorcery.net',
              'reply_to_email_address'     => 'noreply+reply-to-address@technosorcery.net',
              'html_email'                 => false,
              'group_pull_request_updates' => false,
              'alert_on_close'             => true,
              'open_subject'               => 'New pull request: {{title}}',
              'closed_subject'             => 'Closed pull request: {{title}}',
            },
            'jhelwig/Ruby-GitHub-Pull-Request-Bot' => {}
          })
        end

        describe 'with no closed pull requests' do
          it 'should not send any mail' do
            OctocatHerder::PullRequest.stubs(:find_for_repository)
            Pony.expects(:mail).never

            PullRequestBot.new.run
          end
        end

        describe 'with a single closed pull request' do
          before :each do
            OctocatHerder::PullRequest.stubs(:find_for_repository).with('jhelwig', 'Ruby-GitHub-Pull-Request-Bot', 'open').returns([])
            OctocatHerder::PullRequest.stubs(:find_for_repository).with('jhelwig', 'Ruby-GitHub-Pull-Request-Bot', 'closed').returns(
              [OctocatHerder::PullRequest.new(nil, JSON.parse(read_fixture('json/single_repo_single_closed_pull_request.json')))]
            )
          end

          it 'should send a single message' do
            Pony.expects(:mail).once.with(
              :to      => 'noreply+to-address@technosorcery.net',
              :from    => 'noreply+from-address@technosorcery.net',
              :headers => { 'Reply-To' => 'noreply+reply-to-address@technosorcery.net' },
              :body    => read_fixture('json/single_repo_single_closed_pull_request/individual/body.txt'),
              :subject => 'Closed pull request: Determine home directory using $HOME instead of /home/$USER'
            ).returns nil

            PullRequestBot.new.run
          end
        end

        describe 'with multiple closed pull requests' do
          before :each do
            OctocatHerder::PullRequest.stubs(:find_for_repository).with('jhelwig', 'Ruby-GitHub-Pull-Request-Bot', 'open').returns([])
            OctocatHerder::PullRequest.stubs(:find_for_repository).with('jhelwig', 'Ruby-GitHub-Pull-Request-Bot', 'closed').returns(
              JSON.parse(read_fixture('json/single_repo_multiple_closed_pull_requests.json')).map do |req|
                OctocatHerder::PullRequest.new(nil, req)
              end
            )
          end

          it 'should send one message per closed pull request' do
            Pony.expects(:mail).once.with(
              :to      => 'noreply+to-address@technosorcery.net',
              :from    => 'noreply+from-address@technosorcery.net',
              :headers => { 'Reply-To' => 'noreply+reply-to-address@technosorcery.net' },
              :body    => read_fixture('json/single_repo_multiple_closed_pull_requests/individual/body_one.txt'),
              :subject => 'Closed pull request: Capture Diagnostic Information from Failing Tests'
            ).returns nil
            Pony.expects(:mail).once.with(
              :to      => 'noreply+to-address@technosorcery.net',
              :from    => 'noreply+from-address@technosorcery.net',
              :headers => { 'Reply-To' => 'noreply+reply-to-address@technosorcery.net' },
              :body    => read_fixture('json/single_repo_multiple_closed_pull_requests/individual/body_two.txt'),
              :subject => 'Closed pull request: New Test Runner to Produce XML Output for Hudson'
            ).returns nil

            PullRequestBot.new.run
          end

          describe 'grouped per repository' do
            before :each do
              write_config({
                'default' => {
                  'template_dir'               => @template_dir,
                  'state_dir'                  => @state_dir,
                  'to_email_address'           => 'noreply+to-address@technosorcery.net',
                  'from_email_address'         => 'noreply+from-address@technosorcery.net',
                  'reply_to_email_address'     => 'noreply+reply-to-address@technosorcery.net',
                  'html_email'                 => false,
                  'group_pull_request_updates' => true,
                  'alert_on_close'             => true,
                  'open_subject'               => 'New pull request: {{title}}',
                  'closed_subject'             => 'Closed pull requests: {{repository_name}}',
                },
                'jhelwig/Ruby-GitHub-Pull-Request-Bot' => {}
              })
            end

            it 'should send a single message' do
              Pony.expects(:mail).once.with(
                :to      => 'noreply+to-address@technosorcery.net',
                :from    => 'noreply+from-address@technosorcery.net',
                :headers => { 'Reply-To' => 'noreply+reply-to-address@technosorcery.net' },
                :body    => read_fixture('json/single_repo_multiple_closed_pull_requests/grouped/body.txt'),
                :subject => 'Closed pull requests: jhelwig/Ruby-GitHub-Pull-Request-Bot'
              ).returns nil

              PullRequestBot.new.run
            end
          end
        end
      end

      describe 'with multiple configured repositories' do
        before :each do
          @template_dir = File.join(@config_dir, 'templates')
          @state_dir = File.join @config_dir, 'state'
          populate_template_dir(@template_dir, 'text')

          write_config({
            'default' => {
              'template_dir'               => @template_dir,
              'state_dir'                  => @state_dir,
              'to_email_address'           => 'noreply+to-address@technosorcery.net',
              'from_email_address'         => 'noreply+from-address@technosorcery.net',
              'reply_to_email_address'     => 'noreply+reply-to-address@technosorcery.net',
              'html_email'                 => false,
              'group_pull_request_updates' => false,
              'alert_on_close'             => false,
              'open_subject'               => 'New pull request: {{title}}',
            },
            'jhelwig/Ruby-GitHub-Pull-Request-Bot' => { },
            'jhelwig/technosorcery.net'            => { }
          })
        end

        it 'should request the list of open pull requests for each configured repository' do
          OctocatHerder::PullRequest.expects(:find_for_repository).with('jhelwig', 'Ruby-GitHub-Pull-Request-Bot', 'open').returns([])
          OctocatHerder::PullRequest.expects(:find_for_repository).with('jhelwig', 'technosorcery.net', 'open').returns([])

          PullRequestBot.new.run
        end

        describe 'with no open pull requests' do
          it 'should not send any mail' do
            OctocatHerder::PullRequest.stubs(:find_for_repository).returns([])
            Pony.expects(:mail).never

            PullRequestBot.new.run
          end
        end

        describe 'with a single open pull request' do
          describe 'configured to send plain-text messages' do
            before :each do
              OctocatHerder::PullRequest.expects(:find_for_repository).with('jhelwig', 'Ruby-GitHub-Pull-Request-Bot', 'open').returns(
                [OctocatHerder::PullRequest.new(nil, JSON.parse(read_fixture('json/first_repo_single_open_pull_request.json')))]
              )
              OctocatHerder::PullRequest.expects(:find_for_repository).with('jhelwig', 'technosorcery.net', 'open').returns(
                [OctocatHerder::PullRequest.new(nil, JSON.parse(read_fixture('json/second_repo_single_open_pull_request.json')))]
              )
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

              PullRequestBot.new.run
            end
          end
        end

        describe 'with multiple open pull requests' do
          before :each do
            OctocatHerder::PullRequest.expects(:find_for_repository).with('jhelwig', 'Ruby-GitHub-Pull-Request-Bot', 'open').returns(
              JSON.parse(read_fixture('json/first_repo_multiple_open_pull_requests.json')).map do |req|
                OctocatHerder::PullRequest.new(nil, req)
              end
            )
            OctocatHerder::PullRequest.expects(:find_for_repository).with('jhelwig', 'technosorcery.net', 'open').returns(
              JSON.parse(read_fixture('json/second_repo_multiple_open_pull_requests.json')).map do |req|
                OctocatHerder::PullRequest.new(nil, req)
              end
            )
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

              PullRequestBot.new.run
            end

            describe "grouped per repository" do
              before :each do
                write_config({
                  'default' => {
                    'template_dir'               => @template_dir,
                    'state_dir'                  => @state_dir,
                    'to_email_address'           => 'noreply+to-address@technosorcery.net',
                    'from_email_address'         => 'noreply+from-address@technosorcery.net',
                    'reply_to_email_address'     => 'noreply+reply-to-address@technosorcery.net',
                    'html_email'                 => false,
                    'group_pull_request_updates' => true,
                    'alert_on_close'             => false,
                    'open_subject'               => 'New pull requests: {{repository_name}}',
                  },
                  'jhelwig/Ruby-GitHub-Pull-Request-Bot' => { },
                  'jhelwig/technosorcery.net'            => { }
                })
              end

              it 'should send one message per repository' do
                Pony.expects(:mail).once.with(
                  :to      => 'noreply+to-address@technosorcery.net',
                  :from    => 'noreply+from-address@technosorcery.net',
                  :headers => { 'Reply-To' => 'noreply+reply-to-address@technosorcery.net' },
                  :body    => read_fixture('json/first_repo_multiple_open_pull_requests/grouped/body.txt'),
                  :subject => 'New pull requests: jhelwig/technosorcery.net'
                ).returns nil
                Pony.expects(:mail).once.with(
                  :to      => 'noreply+to-address@technosorcery.net',
                  :from    => 'noreply+from-address@technosorcery.net',
                  :headers => { 'Reply-To' => 'noreply+reply-to-address@technosorcery.net' },
                  :body    => read_fixture('json/second_repo_multiple_open_pull_requests/grouped/body.txt'),
                  :subject => 'New pull requests: jhelwig/Ruby-GitHub-Pull-Request-Bot'
                ).returns nil

                PullRequestBot.new.run
              end
            end
          end
        end
      end
    end

    describe 'maintaining state' do
      before :each do
        @template_dir = File.join @config_dir, 'templates'
        @state_dir = File.join @config_dir, 'state'
        populate_template_dir(@template_dir, 'text')
        write_config({
          'default' => {
            'template_dir'               => @template_dir,
            'state_dir'                  => @state_dir,
            'to_email_address'           => 'noreply+to-address@technosorcery.net',
            'from_email_address'         => 'noreply+from-address@technosorcery.net',
            'reply_to_email_address'     => 'noreply+reply-to-address@technosorcery.net',
            'html_email'                 => false,
            'group_pull_request_updates' => false,
            'alert_on_close'             => true,
            'open_subject'               => 'New pull request: {{title}}',
            'closed_subject'             => 'Closed pull request: {{title}}',
          },
          'jhelwig/Ruby-GitHub-Pull-Request-Bot' => {}
        })
      end

      describe 'with open pull requests' do
        before :each do
          OctocatHerder::PullRequest.stubs(:find_for_repository).with('jhelwig', 'Ruby-GitHub-Pull-Request-Bot', 'closed').returns([])
          OctocatHerder::PullRequest.stubs(:find_for_repository).with('jhelwig', 'Ruby-GitHub-Pull-Request-Bot', 'open').returns(
            JSON.parse(read_fixture('json/single_repo_multiple_open_pull_requests.json')).map do |req|
              OctocatHerder::PullRequest.new(nil, req)
            end
          )

          PullRequestBot::RecordedRequests.any_instance.stubs(:open?).with(6).returns(true)
          PullRequestBot::RecordedRequests.any_instance.stubs(:open?).with(8).returns(false)
        end

        it 'should only notify the first time the pull request is seen' do
          Pony.expects(:mail).with(
            :from    => 'noreply+from-address@technosorcery.net',
            :headers => {'Reply-To' => 'noreply+reply-to-address@technosorcery.net'},
            :to      => 'noreply+to-address@technosorcery.net',
            :body    => read_fixture('json/single_repo_multiple_open_pull_requests/individual/pull_eight_body.txt'),
            :subject => 'New pull request: Please pull virtualbox support for the virtual fact'
          )

          PullRequestBot.new.run
        end

        it 'should record the notifications that are sent' do
          Pony.stubs(:mail)
          PullRequestBot::RecordedRequests.any_instance.expects(:open).with(8)

          PullRequestBot.new.run
        end

        describe 'grouping pull requests' do
          before :each do
            write_config({
              'default' => {
                'template_dir'               => @template_dir,
                'state_dir'                  => @state_dir,
                'to_email_address'           => 'noreply+to-address@technosorcery.net',
                'from_email_address'         => 'noreply+from-address@technosorcery.net',
                'reply_to_email_address'     => 'noreply+reply-to-address@technosorcery.net',
                'html_email'                 => false,
                'group_pull_request_updates' => true,
                'alert_on_close'             => true,
                'open_subject'               => 'New pull request: {{repository_name}}',
                'closed_subject'             => 'Closed pull request: {{repository_name}}',
              },
              'jhelwig/Ruby-GitHub-Pull-Request-Bot' => {}
            })
          end

          it 'should not notify when all requests have already been seen' do
            PullRequestBot::RecordedRequests.any_instance.stubs(:open?).with(8).returns(true)

            Pony.expects(:mail).never

            PullRequestBot.new.run
          end
        end
      end

      describe 'with closed pull requests' do
        before :each do
          OctocatHerder::PullRequest.stubs(:find_for_repository).with('jhelwig', 'Ruby-GitHub-Pull-Request-Bot', 'open')
          OctocatHerder::PullRequest.stubs(:find_for_repository).with('jhelwig', 'Ruby-GitHub-Pull-Request-Bot', 'closed').returns(
            JSON.parse(read_fixture('json/single_repo_multiple_closed_pull_requests.json')).map do |req|
              OctocatHerder::PullRequest.new(nil, req)
            end
          )

          PullRequestBot::RecordedRequests.any_instance.stubs(:closed?).with(1).returns(false)
          PullRequestBot::RecordedRequests.any_instance.stubs(:closed?).with(2).returns(true)
        end

        it 'should only notify the first time the pull request is seen' do
          Pony.expects(:mail).once.with(
            :to      => 'noreply+to-address@technosorcery.net',
            :from    => 'noreply+from-address@technosorcery.net',
            :headers => { 'Reply-To' => 'noreply+reply-to-address@technosorcery.net' },
            :body    => read_fixture('json/single_repo_multiple_closed_pull_requests/individual/body_one.txt'),
            :subject => 'Closed pull request: Capture Diagnostic Information from Failing Tests'
          ).returns nil

          PullRequestBot.new.run
        end

        it 'should record the notifications that are sent' do
          Pony.stubs(:mail)
          PullRequestBot::RecordedRequests.any_instance.expects(:close).with(1)

          PullRequestBot.new.run
        end

        describe 'grouping pull requests' do
          before :each do
            write_config({
              'default' => {
                'template_dir'               => @template_dir,
                'state_dir'                  => @state_dir,
                'to_email_address'           => 'noreply+to-address@technosorcery.net',
                'from_email_address'         => 'noreply+from-address@technosorcery.net',
                'reply_to_email_address'     => 'noreply+reply-to-address@technosorcery.net',
                'html_email'                 => false,
                'group_pull_request_updates' => true,
                'alert_on_close'             => true,
                'open_subject'               => 'New pull request: {{repository_name}}',
                'closed_subject'             => 'Closed pull request: {{repository_name}}',
              },
              'jhelwig/Ruby-GitHub-Pull-Request-Bot' => {}
            })
          end

          it 'should not notify when all requests have already been seen' do
            PullRequestBot::RecordedRequests.any_instance.stubs(:closed?).with(1).returns(true)

            Pony.expects(:mail).never

            PullRequestBot.new.run
          end
        end
      end
    end

    describe 'templating' do
      it 'should support template snippits relative to the template_dir setting' do
        @template_dir = File.join(@config_dir, 'templates')
        @state_dir    = File.join(@config_dir, 'state')
        populate_template_dir(@template_dir, 'with_snippits')

        write_config({
            'default' => {
              'template_dir'               => @template_dir,
              'state_dir'                  => @state_dir,
              'to_email_address'           => 'noreply+to-address@technosorcery.net',
              'from_email_address'         => 'noreply+from-address@technosorcery.net',
              'reply_to_email_address'     => 'noreply+reply-to-address@technosorcery.net',
              'html_email'                 => false,
              'group_pull_request_updates' => false,
              'alert_on_close'             => false,
              'open_subject'               => 'New pull request: {{title}}',
            },
            'jhelwig/Ruby-GitHub-Pull-Request-Bot' => {}
        })

        OctocatHerder::PullRequest.stubs(:find_for_repository).returns(
          [OctocatHerder::PullRequest.new(nil, JSON.parse(read_fixture('json/single_repo_single_open_pull_request.json')))]
        )

        Pony.expects(:mail).once.with(
          :to      => 'noreply+to-address@technosorcery.net',
          :from    => 'noreply+from-address@technosorcery.net',
          :headers => { 'Reply-To' => 'noreply+reply-to-address@technosorcery.net' },
          :body    => read_fixture('json/single_repo_single_open_pull_request/individual-snippit/body.txt'),
          :subject => 'New pull request: Resolve encoding errors in Ruby 1.9'
        ).returns nil

        PullRequestBot.new.run
      end

      it 'should support sending email with HTML body' do
        @template_dir = File.join(@config_dir, 'templates')
        @state_dir    = File.join(@config_dir, 'state')
        populate_template_dir(@template_dir, 'html')

        write_config({
            'default' => {
              'template_dir'               => @template_dir,
              'state_dir'                  => @state_dir,
              'to_email_address'           => 'noreply+to-address@technosorcery.net',
              'from_email_address'         => 'noreply+from-address@technosorcery.net',
              'reply_to_email_address'     => 'noreply+reply-to-address@technosorcery.net',
              'html_email'                 => true,
              'group_pull_request_updates' => false,
              'alert_on_close'             => false,
              'open_subject'               => 'New pull request: {{title}}',
            },
            'jhelwig/Ruby-GitHub-Pull-Request-Bot' => {}
        })

        OctocatHerder::PullRequest.stubs(:find_for_repository).returns(
          [OctocatHerder::PullRequest.new(nil, JSON.parse(read_fixture('json/single_repo_single_open_pull_request.json')))]
        )

        Pony.expects(:mail).once.with(
          :to        => 'noreply+to-address@technosorcery.net',
          :from      => 'noreply+from-address@technosorcery.net',
          :headers   => { 'Reply-To' => 'noreply+reply-to-address@technosorcery.net' },
          :html_body => read_fixture('json/single_repo_single_open_pull_request/individual/body.html'),
          :subject   => 'New pull request: Resolve encoding errors in Ruby 1.9'
        ).returns nil

        PullRequestBot.new.run
      end

      it 'should support sending email with text body' do
        @template_dir = File.join(@config_dir, 'templates')
        @state_dir    = File.join(@config_dir, 'state')
        populate_template_dir(@template_dir, 'text')

        write_config({
            'default' => {
              'template_dir'               => @template_dir,
              'state_dir'                  => @state_dir,
              'to_email_address'           => 'noreply+to-address@technosorcery.net',
              'from_email_address'         => 'noreply+from-address@technosorcery.net',
              'reply_to_email_address'     => 'noreply+reply-to-address@technosorcery.net',
              'html_email'                 => false,
              'group_pull_request_updates' => false,
              'alert_on_close'             => false,
              'open_subject'               => 'New pull request: {{title}}',
            },
            'jhelwig/Ruby-GitHub-Pull-Request-Bot' => {}
        })

        OctocatHerder::PullRequest.stubs(:find_for_repository).returns(
          [OctocatHerder::PullRequest.new(nil, JSON.parse(read_fixture('json/single_repo_single_open_pull_request.json')))]
        )

        Pony.expects(:mail).once.with(
          :to      => 'noreply+to-address@technosorcery.net',
          :from    => 'noreply+from-address@technosorcery.net',
          :headers => { 'Reply-To' => 'noreply+reply-to-address@technosorcery.net' },
          :body    => read_fixture('json/single_repo_single_open_pull_request/individual/body.txt'),
          :subject => 'New pull request: Resolve encoding errors in Ruby 1.9'
        ).returns nil

        PullRequestBot.new.run
      end

      it 'should send the repository_name to the template' do
        @template_dir = File.join(@config_dir, 'templates')
        @state_dir    = File.join(@config_dir, 'state')
        populate_template_dir(@template_dir, 'text')

        write_config({
            'default' => {
              'template_dir'               => @template_dir,
              'state_dir'                  => @state_dir,
              'to_email_address'           => 'noreply+to-address@technosorcery.net',
              'from_email_address'         => 'noreply+from-address@technosorcery.net',
              'reply_to_email_address'     => 'noreply+reply-to-address@technosorcery.net',
              'html_email'                 => false,
              'group_pull_request_updates' => false,
              'alert_on_close'             => false,
              'open_subject'               => 'New pull request: {{title}}',
            },
            'jhelwig/Ruby-GitHub-Pull-Request-Bot' => {}
        })

        OctocatHerder::PullRequest.stubs(:find_for_repository).returns(
          [OctocatHerder::PullRequest.new(nil, JSON.parse(read_fixture('json/single_repo_single_open_pull_request.json')))]
        )
        Mustache.expects(:render).at_least_once.with do |template, request|
          request.should have_key('repository_name')
          request['repository_name'].should == 'jhelwig/Ruby-GitHub-Pull-Request-Bot'
        end
        Pony.stubs(:mail)

        PullRequestBot.new.run
      end
    end
  end

  def write_config(contents)
    write_file @config_file, YAML.dump(contents)
  end

  def write_file(path, contents)
    full_path = File.join @config_dir, path
    FileUtils.mkdir_p(File.dirname(full_path))
    File.open(full_path, 'w') {|f| f.write contents}
  end
end
