#!/usr/bin/env ruby

require 'json'
require 'rest_client'

class UptimeRobotCLI
  def initialize
    @env = ENV['UPTIMEROBOT_ENV']
    @accounts = JSON.parse(File.read('./config/accounts.json'))[@env]
    @mappings = JSON.parse(File.read('./config/mappings.json'))
    @config = @accounts.merge(JSON.parse(File.read("./config/#{@env}.json"))).
      merge(@mappings)
    @site = RestClient::Resource.new('http://api.uptimerobot.com')
    @common_payload = {
      :apiKey => @config['account_api_key'],
      :format => @config['format']
    }
  end

  def show_config
    puts JSON.pretty_generate(@config)
  end

  def parse_response(string)
    JSON.parse(string[/^jsonUptimeRobotApi\((.*)\)$/,1])
  end

  def dump_monitors
    payload = @common_payload
    payload[:logs] = 1
    payload[:alertContacts] = 1
    response = @site['getMonitors'].get :params => payload, :accept => :json
    result = parse_response(response)
    result['stat'] == 'ok' ? result['monitors']['monitor'] : nil
  end

  def int_exclude_logs(monitors)
    monitors.each do |m|
      m.tap do |h|
        ['log','alltimeuptimeratio'].each do |k|
          h.delete(k)
        end # each
      end # tap
    end unless monitors.nil?# each 
  end # def

  def monitors
    int_exclude_logs(dump_monitors)
  end

  def logs
    JSON.pretty_generate(dump_monitors)
  end

  def contacts
    payload = @common_payload
    response = @site['getAlertContacts'].get :params => payload, :accept => :json
    result = parse_response(response)
    result['stat'] == 'ok' ? result['alertcontacts']['alertcontact'] : nil
  end

  def dump
    dump = {
      'contacts' => contacts,
      'monitors' => monitors
    }
    File.write("./config/#{Time.now.strftime('%Y-%m-%d-%H-%M')}-#{@env}.json",JSON.pretty_generate(dump))
  end

  def full_dump
    dump = {
      'contacts' => contacts,
      'monitors' => dump_monitors
    }
    File.write("./config/#{Time.now.strftime('%Y-%m-%d-%H-%M')}-#{@env}.json",JSON.pretty_generate(dump))
  end

  def create_monitor(monitor)
    payload = @common_payload
    @config['mappings']['newMonitor'].each do |k,v|
      if monitor[k] then 
        payload[v] = monitor[k]
      end
    end
    response = @site['newMonitor'].get :params => payload, :content_type => :json, :accept => :json
    result = parse_response(response)
  end

  def edit_monitor(monitor)
    payload = @common_payload
    @config['mappings']['editMonitor'].each do |k,v|
      if monitor[k] then 
        payload[v] = monitor[k]
      end
    end
    response = @site['editMonitor'].get :params => payload, :content_type => :json, :accept => :json
    result = parse_response(response)
  end

  def update_monitors
    @config['monitors'].each do |monitor|
      if monitor['id'] then
        if monitor['deleted'] then
          delete_monitor monitor
        else
          edit_monitor monitor
        end
      else
        create_monitor monitor
      end
    end
  end

  def delete_monitor(monitor)
    payload = {
      :apiKey => @config['account_api_key'],
      :format => @config['format'],
      :monitorID => monitor['id']
    }
    response = @site['deleteMonitor'].get :params => payload, :content_type => :json, :accept => :json
    result = parse_response(response)
  end

  def delete_monitors
    @config['monitors'].each do |monitor|
      delete_monitor monitor
    end
  end


  def create_contact(contact)
    payload = {
      :apiKey => @config['account_api_key'],
      :format => @config['format'],
      :alertContactType => contact['type'],
      :alertContactValue => contact['value']
    }
    response = @site['newAlertContact'].get :params => payload, :content_type => :json, :accept => :json
    result = parse_response(response)
  end

  def create_contacts
    @config['contacts'].each do |contact|
      next if contact['id']
      create_contact contact
    end
  end

  def delete_contact(contact)
    payload = {
      :apiKey => @config['account_api_key'],
      :format => @config['format'],
      :alertContactID => contact['id']
    }
    response = @site['deleteAlertContact'].get :params => payload, :accept => :json
    result = parse_response(response)
  end

  def delete_contacts
    @config['contacts'].each do |contact|
      delete_contact contact
    end
  end

end

cli = UptimeRobotCLI.new

# dynamic dispatch
method_name = ARGV[0]
cli.public_send(method_name) if cli.respond_to? method_name
puts "Dumping data..."
cli.dump
