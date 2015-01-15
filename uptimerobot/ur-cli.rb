#!/usr/bin/env ruby

require 'yaml'
require 'rest_client'
require 'json'

class UptimeRobotCLI

  def initialize
    env=ENV['UPTIMEROBOT_ENV']
    @config = YAML::load(File.open("./config/settings.yml"))[env]
    @site = RestClient::Resource.new('http://api.uptimerobot.com')
  end

  def show_config
    puts @config.to_yaml  
  end

  def account_details
    @site['getAccountDetails'].get :params => {:apiKey => @config['account_api_key'], :format => "json"}, :accept => :json
  end

  def monitors
    @site['getMonitors'].get :params => {:apiKey => @config['account_api_key'], :logs => 1, :alertContacts => 1, :format => "json"}, :accept => :json
  end

  def contacts
    @site['getAlertContacts'].get :params => {:apiKey => @config['account_api_key'], :format => "json"}, :accept => :json
  end

  def create_monitors
    @config['monitors'].each do |monitor|
      next if monitor['id']
      payload = {
        :apiKey => @config['account_api_key'],
        :monitorFriendlyName => monitor['friendlyname'],
        :monitorURL => monitor['url'],
        :monitorType => monitor['type'],
        :monitorKeywordType => monitor['keywordtype'],
        :monitorKeywordValue => monitor['keywordvalue'],
        :monitorAlertContacts => monitor['alertcontacts'].join('-')
      }
      @site['newMonitor'].post payload.to_json, :content_type => :json, :accept => :json
    end
  end
end

cli = UptimeRobotCLI.new

# dynamic dispatch
method_name = ARGV[0]
puts cli.public_send(method_name) if cli.respond_to? method_name

