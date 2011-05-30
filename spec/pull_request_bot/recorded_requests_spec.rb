#!/usr/bin/env ruby

require 'spec_helper'
require 'pull_request_bot/recorded_requests'

describe PullRequestBot::RecordedRequests do
  let(:recorded_requests) do
    PullRequestBot::RecordedRequests.new(@state_dir, @repository_name)
  end

  before :each do
    @state_dir = Dir.mktmpdir
    @repository_name = 'jhelwig/Ruby-GitHub-Pull-Request-Email-Bot'

    @open_requests = File.join(@state_dir, @repository_name, 'open_requests')
    @closed_requests = File.join(@state_dir, @repository_name, 'closed_requests')
  end

  after :each do
    FileUtils.rm_rf @state_dir
  end

  describe 'when instantiated' do
    before :each do
      recorded_requests
    end

    it 'should auto-create an open_requests state file based on the state_dir, and repository name' do
      File.should be_file(@open_requests)
    end

    it 'should auto-create a closed_requests state file based on the state_dir, and repository name' do
      File.should be_file(@closed_requests)
    end
  end

  describe 'when dealing with open pull requests' do
    before :each do
      recorded_requests.open(1)
    end

    it 'should add the pull request to the open_requests state file' do
      @open_requests.should contain_recorded_requests(1)
    end

    it 'should report the pull request as being open' do
      recorded_requests.should be_open(1)
    end

    it 'should not report the pull request as being closed' do
      recorded_requests.should_not be_closed(1)
    end
  end

  describe 'when dealing with multiple open pull requests' do
    before :each do
      recorded_requests.open(1, 2, 3)
    end

    it 'should add the pull request to the open_requests state file' do
      @open_requests.should contain_recorded_requests(1, 2, 3)
    end

    it 'should report the pull requests as being open' do
      recorded_requests.should be_open(1)
      recorded_requests.should be_open(2)
      recorded_requests.should be_open(3)
    end

    it 'should not report the pull requests as being closed' do
      recorded_requests.should_not be_closed(1)
      recorded_requests.should_not be_closed(2)
      recorded_requests.should_not be_closed(3)
    end
  end

  describe 'when dealing with closed pull requests' do
    before :each do
      recorded_requests.close(1)
    end

    it 'should add the pull request to the closed_requests state file' do
      @closed_requests.should contain_recorded_requests(1)
    end

    it 'should report the pull request as being closed' do
      recorded_requests.should be_closed(1)
    end

    it 'should not report the pull request as being open' do
      recorded_requests.should_not be_open(1)
    end
  end

  describe 'when dealing with multiple closed pull requests' do
    before :each do
      recorded_requests.close(1, 2, 3)
    end

    it 'should add the pull request to the closed_requests state file' do
      @closed_requests.should contain_recorded_requests(1, 2, 3)
    end

    it 'should report the pull request as being closed' do
      recorded_requests.should be_closed(1)
      recorded_requests.should be_closed(2)
      recorded_requests.should be_closed(3)
    end

    it 'should not report the pull request as being open' do
      recorded_requests.should_not be_open(1)
      recorded_requests.should_not be_open(2)
      recorded_requests.should_not be_open(3)
    end
  end

  describe 'when an open pull request is closed' do
    before :each do
      FileUtils.mkdir_p(File.dirname(@open_requests))

      File.open(@open_requests, 'w') do |f|
        f.puts 1,2,3
      end

      File.open(@closed_requests, 'w') do |f|
        f.puts 4,5,6
      end

      recorded_requests.close(1)
    end

    it 'should add the pull request to the closed_requests state file' do
      @closed_requests.should contain_recorded_requests(1, 4, 5, 6)
    end

    it 'should remove the pull request from the open_requests state file' do
      @open_requests.should_not contain_recorded_requests(1)
    end

    it 'should not remove any other entries from the open_requests state file' do
      @open_requests.should contain_recorded_requests(2, 3)
    end

    it 'should report the pull request as being closed' do
      recorded_requests.should be_closed(1)
    end

    it 'should not report the pull request as being open' do
      recorded_requests.should_not be_open(1)
    end
  end

  describe 'when a closed pull request is re-opened' do
    before :each do
      FileUtils.mkdir_p(File.dirname(@open_requests))

      File.open(@closed_requests, 'w') do |f|
        f.puts 1,2,3
      end

      File.open(@open_requests, 'w') do |f|
        f.puts 4,5,6
      end

      recorded_requests.open(1)
    end

    it 'should add the pull request to the open_requests state file' do
      @open_requests.should contain_recorded_requests(1, 4, 5, 6)
    end

    it 'should remove the pull request from the closed_requests state file' do
      @closed_requests.should_not contain_recorded_requests(1)
    end

    it 'should not remove any other entries from the closed_requests state file' do
      @closed_requests.should contain_recorded_requests(2, 3)
    end

    it 'should report the pull request as being open' do
      recorded_requests.should be_open(1)
    end

    it 'should not report the pull request as being closed' do
      recorded_requests.should_not be_closed(1)
    end
  end
end

RSpec::Matchers.define :contain_recorded_requests do |*expected|
  match do |actual|
    File.readlines(actual).map(&:chomp).reject(&:empty?).map(&:to_i).sort == expected.sort
  end

  failure_message_for_should do |actual|
    actual_file_contents = File.readlines(actual).map(&:chomp).reject(&:empty?).map(&:to_i)
    missing_requests = expected - actual_file_contents
    extra_requests = actual_file_contents - expected

    message = "expected #{actual.inspect} to contain recorded requests #{expected.inspect}\n"
    message << "actual file contained: #{actual_file_contents.inspect}\n"
    message << "missing requests:      #{missing_requests.inspect}\n" unless missing_requests.empty?
    message << "extra requests:        #{extra_requests.inspect}"   unless extra_requests.empty?

    message
  end

  failure_message_for_should_not do |actual|
    actual_file_contents = File.readlines(actual).map(&:chomp).reject(&:empty?).map(&:to_i)
    extra_requests = actual_file_contents - (actual_file_contents - expected_file_contents)

    message = "expected #{actual.inspect} to not contain recorded requests #{expected.inspect}\n"
    message << "actual file contained: #{actual_file_contents.inspect}\n"
    message << "extra requests:        #{extra_requests.inspect}"   unless extra_requests.empty?

    message
  end
end
