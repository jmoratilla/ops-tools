#!/usr/bin/env ruby

require 'json'
require 'rest_client'

class UptimeRobotCLI
  def initialize
    @env = ENV['UPTIMEROBOT_ENV']
    @config = JSON.parse(File.read('./config/accounts.json'))[@env]
    @site = RestClient::Resource.new('http://api.uptimerobot.com')
  end

  def show_config
    puts @config  
  end

  def parse_response(string)
    JSON.parse(string[/^jsonUptimeRobotApi\((.*)\)$/,1])
  end

  def monitors
    payload = {
      :apiKey => @config['account_api_key'],
      :format => @config['format'],
      :logs => 1,
      :alertContacts => 1
    }
    response = @site['getMonitors'].get :params => payload, :accept => :json
    result = parse_response(response)
    result['stat'] == 'ok' ? result['monitors']['monitor'] : nil
  end

  def contacts
    payload = {
      :apiKey => @config['account_api_key'],
      :format => @config['format']
    }
    response = @site['getAlertContacts'].get :params => payload, :accept => :json
    result = parse_response(response)
    result['stat'] == 'ok' ? result['alertcontacts']['alertcontact'] : nil
  end

  def dump_data
    data = {
      'contacts' => contacts,
      'monitors' => monitors
    }
    
    File.write("./config/#{Time.now}-#{@env}.json",JSON.pretty_generate(data))
  end

end

cli = UptimeRobotCLI.new

# dynamic dispatch
method_name = ARGV[0]
puts cli.public_send(method_name) if cli.respond_to? method_name
