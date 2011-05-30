require 'rubygems'
require 'httparty'
require 'mustache'
require 'pony'
require 'trollop'
require 'yaml'

class PullRequestBot
  include HTTParty
  base_uri 'https://github.com/api/v2/json'

  attr_accessor :opts, :config

  def initialize
    self.opts = Trollop::options do
      opt :config, "Specify config file to use", :type => :string, :default => './config.yaml'
    end

    read_config
    validate_config
  end

  def run
    repositories.each do |repository, settings|
      handle_pull_requests(repository, settings, :open)
      handle_pull_requests(repository, settings, :closed) if settings['alert_on_close']
    end
  end

  def repositories
    unless @repositories
      @repositories = config.reject {|k,v| k == "default"}

      @repositories.keys.each do |repository|
        @repositories[repository] = config['default'].merge(config[repository])
      end
    end

    @repositories
  end

  private

  def handle_pull_requests(repository, settings, status)
    pull_requests = PullRequestBot.get("/pulls/#{repository}/#{status}")
    return unless pull_requests.has_key?('pulls') and not pull_requests['pulls'].empty?

    Mustache.template_path = settings['template_dir']

    body_type = settings['html_email'] ? :html_body : :body

    if settings['group_pull_request_updates']
      template_prefix = 'group'
      pull_requests = [pull_requests]
    else
      template_prefix = 'individual'
      pull_requests = pull_requests['pulls']
    end

    pull_requests.each do |request|
      request.merge!('repository_name' => repository)

      body = Mustache.render(
        File.read(File.join(settings['template_dir'], "#{template_prefix}_#{status}.mustache")),
        request
      )
      subject = Mustache.render(settings["#{status}_subject"], request)

      Pony.mail(
        :to       => settings["to_email_address"],
        :from     => settings["from_email_address"],
        :headers  => { 'Reply-To' => settings["reply_to_email_address"] },
        body_type => body,
        :subject  => subject
      )
    end
  end

  def read_config
    self.config = YAML.load(File.read(opts[:config]))
  end

  def validate_config
    raise ArgumentError.new("In '#{opts[:config]}' there must be a 'default' section.") unless
      config && config.is_a?(Hash) && config['default']

    # Enumerate all of the 'globally required' default settings,
    # making sure that each one is there.
    %w{
     template_dir
     state_dir
     to_email_address
     from_email_address
     reply_to_email_address
     html_email
     group_pull_request_updates
     alert_on_close
     open_subject
    }.each do |key|
      raise ArgumentError.new("In '#{opts[:config]}' the 'default' section must contain '#{key}'") unless
        config['default'].has_key?(key)
    end

    raise ArgumentError.new("In '#{opts[:config]}' the 'default' section must contain 'closed_subject' when 'alert_on_close' is true.") if
      config['default']['alert_on_close'] and not config['default'].has_key?('closed_subject')

    raise ArgumentError.new("There must be at least one repository configured (user-name/repository-name)") unless
      config.keys.count > 1

    config.keys.each do |section|
      next if section == "default"

      raise ArgumentError.new("Repositories must be of the form 'user-name/repository-name': #{section}") unless
        section.match /[a-z0-9_-]+\/[a-z0-9_-]+/i
    end
  end
end
