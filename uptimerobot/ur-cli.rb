#!/usr/bin/env ruby

require 'yaml'
require 'rest_client'
require 'json'

class UptimeRobotCLI

  def initialize
    env=ENV['UPTIMEROBOT_ENV']
    @config = YAML::load_file("./config/settings.yml")[env]
    @site = RestClient::Resource.new('http://api.uptimerobot.com')
  end

  def parse_response(string)
    JSON.parse(string[/^jsonUptimeRobotApi\((.*)\)$/,1])
  end

  def show_config
    puts @config.to_yaml  
  end

  def save_config(target,config)
    File.write("./config/#{target}.yml",config.to_yaml)
  end

  def account_details
    response = @site['getAccountDetails'].get :params => {:apiKey => @config['account_api_key'], :format => @config['format']}, :accept => :json
    parse_response(response)
  end

  def monitors
    response = @site['getMonitors'].get :params => {:apiKey => @config['account_api_key'], :logs => 0, :alertContacts => 0, :format => @config['format']}, :accept => :json
    result = parse_response(response)
    result['monitors']['monitor']
  end

  def contacts
    response = @site['getAlertContacts'].get :params => {:apiKey => @config['account_api_key'], :format => @config['format']}, :accept => :json
    result = parse_response(response)
  end

  # This should create new or edit existing monitors
  def create_monitors
    @config['monitors'].each do |monitor|
      next if monitor['id']
      payload = {
        :apiKey => @config['account_api_key'],
        :format => @config['format'],
        :monitorFriendlyName => monitor['friendlyname'],
        :monitorURL => monitor['url'],
        :monitorType => monitor['type'],
        :monitorKeywordType => monitor['keywordtype'],
        :monitorKeywordValue => monitor['keywordvalue'],
        :monitorAlertContacts => monitor['alertcontacts'].join('-')
      }

      response = @site['newMonitor'].get :params => payload, :content_type => :json, :accept => :json
      result = parse_response(response)

      puts result

      if response.code == 200 then
        monitor['id'] = result['monitor']['id']
      end
    end
    save_config(@config)
  end

  def delete_monitors
    @config['monitors'].each do |monitor|
      payload = {
        :apiKey => @config['account_api_key'],
        :format => @config['format'],
        :monitorID => monitor['id']
      }
      response = @site['deleteMonitor'].get :params => payload, :content_type => :json, :accept => :json
      result = parse_response(response)
    end
  end
end

cli = UptimeRobotCLI.new

# dynamic dispatch
method_name = ARGV[0]
puts cli.public_send(method_name) if cli.respond_to? method_name

