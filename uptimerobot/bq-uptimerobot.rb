#!/usr/bin/env ruby

require 'json'
require 'rest_client'
require 'set'
require 'logger'
require 'optparse'

class UptimeRobotCLI
  attr_accessor :loglevel

  def initialize(env)
    @env = env
    @log = Logger.new(STDOUT)
    @log.level = Logger::INFO

    # We join json files from config dir...
    this_dir = File.dirname(__FILE__)
    tmp = Dir[ this_dir + '/config/settings.json', this_dir + "/config/#{@env}.json"].map { |file|
       JSON.parse(File.read(file))
    }
    # and merge them into one hash (@config)
    @config = tmp.reduce({}) do |t,d|
      deep_merge(t,d)
    end

    # Let's check we have an account, or quit quick
    if @config['accounts'][@env].nil? then
      puts ("initialize: there is no account #{@env}")
      exit 1
    end

    # Initialize the rest_client connection    
    @site = RestClient::Resource.new('http://api.uptimerobot.com')
    
    # Generate a common set of attributes to send in each request
    @common_payload = {
      :apiKey => @config['accounts'][@env]['key'],
      :format => @config['format']
    }

    # Generate a config dump if the log = Logger::DEBUG
    @log.debug("initialize config: #{@config}")
    @log.debug("initialize payload: #{@common_payload}")
  end


  # shows the @config hash
  def show_config
    puts JSON.pretty_generate(@config)
  end

  def loglevel=(loglevel)
    @log.level = loglevel
  end

  # send updates to uptimerobot
  def update
    dump_to_memory
    ['contacts','monitors'].each do |category|
      actions = extract_actions(category)
      @log.info("update actions: #{actions}")
      send_actions(category,actions)
    end
  end

  # generate a JSON with the configuration in uptimerobot
  def dump
    dump = {
      "#{@env}" => {
        'contacts' => contacts,
        'monitors' => monitors_filtered
      }
    }
    File.write("./data/#{Time.now.strftime('%Y-%m-%d-%H-%M')}-#{@env}.json",JSON.pretty_generate(dump))
  end

  # pause monitors
  def pause(string)
    @config[@env]['monitors'].each do |m|
      next unless m['friendlyname'].match(/#{string}/)
      action = {
        'id' => m['id'],
        'friendlyname' => m['friendlyname'],
        'status' => "0"
      }
      @log.info("pause: #{action}")
      edit_monitor(action)
    end
  end

  # start monitors
  def start(string)
    @config[@env]['monitors'].each do |m|
      next unless m['friendlyname'].match(/#{string}/)
      action = {
        'id' => m['id'],
        'friendlyname' => m['friendlyname'],
        'status' => "1"
      }
      @log.info("start: #{action}")
      edit_monitor(action)
    end
  end


  private
  # helper method used to merge hashes
  def deep_merge(h1, h2)
    h1.merge(h2) { |key, h1_elem, h2_elem| deep_merge(h1_elem, h2_elem) }
  end


  # filters response to remove unwanted stuff
  def parse_response(string)
#    @log.debug("parse_response: #{string}")
    result = ''
    if string.include?('jsonUptimeRobotApi') then
      result = string[/^jsonUptimeRobotApi\((.*)\)$/,1]
    else
      result = string
    end
    JSON.parse(result)
  end

  # downloads monitors, logs and contacts from uptimerobot
  def monitors
    payload = @common_payload.clone
    payload[:logs] = 1
    payload[:alertcontacts] = 1
    payload[:showMonitorAlertContacts] = 1
    response = @site['getMonitors'].get :params => payload, :accept => :json
    result = parse_response(response)
    result['stat'] == 'ok' ? result['monitors']['monitor'] : nil
  end

  # removes unwanted data downloaded and
  # rewrites the alertcontacts attribute to add monitor contacts
  def clean_monitors(monitors)
    monitors.each do |m|
      m.tap do |h|
        h['alertcontacts'] = extract_contacts_from_monitor(m)
        h['interval'] = (h['interval'].to_i / 60).to_s
        ['log','alltimeuptimeratio','alertcontact'].each do |k|
          h.delete(k)
        end # each
      end # tap
    end unless monitors.nil?# each 
  end # def

  # contacts from hash to string
  def extract_contacts_from_monitor(monitor)
    contacts = Set.new
    unless monitor['alertcontact'].nil? then
      monitor['alertcontact'].each do |c|
        contacts.add(c['id'])
      end
    end
    contacts.to_a.join('-')
  end

  # when we don't want logs
  def monitors_filtered
    clean_monitors(monitors)
  end

  # when we want logs
  def logs
    JSON.pretty_generate(monitors)
  end

  # downloads contacts from uptimerobot
  def contacts
    payload = @common_payload.clone
    @log.debug("contacts payload: #{JSON.pretty_generate(payload)}")
    response = @site['getAlertContacts'].get :params => payload, :accept => :json
    result = parse_response(response)
    @log.debug("contacts result: #{JSON.pretty_generate(result)}")
    result['stat'] == 'ok' ? result['alertcontacts']['alertcontact'] : nil
  end

  def create_monitor(monitor)
    payload = @common_payload.clone
    @config['mappings']['newMonitor'].each do |k,v|
      if monitor[k] then 
        payload[v] = monitor[k]
      end
    end
    @log.debug("edit_monitor payload: #{JSON.pretty_generate(payload)}")
    response = @site['newMonitor'].get :params => payload, :content_type => :json, :accept => :json
    result = parse_response(response)
    @log.debug("create_monitor result: #{JSON.pretty_generate(result)}")
    result
  end

  def edit_monitor(monitor)
    payload = @common_payload.clone
    @config['mappings']['editMonitor'].each do |k,v|
      if monitor[k] then 
        payload[v] = monitor[k]
      end
    end
    @log.debug("edit_monitor payload: #{JSON.pretty_generate(payload)}")
    response = @site['editMonitor'].get :params => payload, :content_type => :json, :accept => :json
    result = parse_response(response)
    @log.debug("edit_monitor result: #{JSON.pretty_generate(result)}")
    result
  end

  def update_monitors(monitors)
    @log.debug("update_monitors begin")
    monitors.each do |monitor|
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
    @log.debug("update_monitors end")
  end

  def delete_monitor(monitor)
    payload = @common_payload.clone
    payload[:monitorID] =  monitor['id']
    @log.debug("delete_monitor payload: #{payload}")
    response = @site['deleteMonitor'].get :params => payload, :content_type => :json, :accept => :json
    result = parse_response(response)
    @log.debug("delete_monitor: #{JSON.pretty_generate(result)}")
    result
  end

  def create_contact(contact)
    payload = @common_payload.clone
    payload[:alertContactType] = contact['type']
    payload[:alertContactValue] = contact['value']
    response = @site['newAlertContact'].get :params => payload, :content_type => :json, :accept => :json
    result = parse_response(response)
  end

  def delete_contact(contact)
    payload = @common_payload.clone
    payload[:alertContactID] = contact['id']
    response = @site['deleteAlertContact'].get :params => payload, :accept => :json
    result = parse_response(response)
  end

  def update_contacts(contacts)
    contacts.each do |contact|
      if contact['id'] then
        if contact['deleted'] then
          delete_contact contact
        end
      else
        create_contact contact
      end
    end
  end



  def dump_to_memory
    dump = {
      "#{@env}" => {
        'contacts' => contacts,
        'monitors' => monitors_filtered
      }
    }
    @old_config = dump
  end

  def full_dump
    dump = {
      "#{@env}" => {
        'contacts' => contacts,
        'monitors' => monitors
      }
    }
    File.write("./data/#{Time.now.strftime('%Y-%m-%d-%H-%M')}-#{@env}.json",JSON.pretty_generate(dump))
  end

  # Reads one hash and per entry, and find the same entry in the other hash to extract differences
  def diff_extractor(hnew,hold,key_attr)
    @final = []

    hnew.each do |i|
      result = {
        "#{key_attr}" => i[key_attr] || ""
      }
      if i[key_attr].nil? then 
        result = i.clone
      else
        hold.each do |j| # => 
          next unless i[key_attr].eql? j[key_attr]
          i.keys.each do |k|
            unless i[k].eql? j[k] then
              result[k] = i[k]
            end
          end
        end
      end
      @final << result
    end
    @final
  end

  def extract_actions(category)
    actions = diff_extractor(@config[@env][category],@old_config[@env][category],'id') || []
    @log.debug("extract_actions: #{actions}")
    actions
  end

  def send_actions(category,actions)
    case category
    when 'monitors'
      update_monitors(actions)
    when 'contacts'
      update_contacts(actions)
    end
  end

end


def syntaxis
  'Usage: bq-uptimerobot.rb [-h] | -a account command [parameters] -d '
end

options = {}
OptionParser.new do |opts|
  opts.banner = syntaxis

  opts.on('-a', '--account ACCOUNT', 'UptimeRobot account') do |account|
    options[:account] = account
  end

  opts.on('-d', '--debug', 'Enable debug level') do |debug|
    options[:debug] = true
  end
end.parse!

if options == {} then
  puts syntaxis
  exit 1
end

begin
  puts options
end if options[:verbose]


urcli = UptimeRobotCLI.new(options[:account])

if options[:debug] then
  urcli.loglevel = Logger::DEBUG 
end
# dynamic dispatch
method_name = ARGV[0]

if method_name.match(/pause/) then
  urcli.pause(ARGV[1])
elsif method_name.match(/start/) then
  urcli.start(ARGV[1])
else
  urcli.public_send(method_name) if urcli.respond_to? method_name 
end
