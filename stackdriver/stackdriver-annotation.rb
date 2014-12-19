#!/usr/bin/env ruby
# encoding: UTF-8

# You need an STACKDRIVER_API_KEY env variable

require 'rest_client'
require 'optparse'
require 'json'

def syntaxis
  "#{$0} -p project -m message [-t YYYY-MM-DD-HH-mm]"
end

def time_converter(datetime)
      t = datetime.split '-'
      Time.new(*t).to_i
end

options = {}
OptionParser.new do |opts|
  opts.banner = syntaxis

  opts.on('-c', '--config FILE', 'config file') do |c|
    options[:config] = c
  end

  opts.on('-p', '--project PROJECT', 'Name of the project') do |p|
    options[:project] = p
  end

  opts.on('-m', '--message TEXT', 'Message to send') do |m|
    options[:message] = m
  end

  opts.on('-l', '--level LEVEL', 'The log level: ') do |l|
    options[:level] = l
  end

  opts.on('-v', '--[no-]verbose', 'Run verbosely') do |v|
    options[:verbose] = v
  end

  opts.on('-t', '--time YYYY-MM-DD-HH-mm', 'Time when the annotation will be noted') do |t|
    options[:time] = time_converter(t)
  end
end.parse!

if options == {} then
  puts syntaxis
  exit 1
end

begin
  puts options
end if options[:verbose]

# @config = JSON.parse(File.read(options[:config] ? options[:config] : './config.json'))
@config = { "api_key" => ENV['STACKDRIVER_API_KEY'] }

message = "#{options[:project]}: #{options[:message]}"

payload = {
  'message' =>  message,
  'level'   =>  options[:level] || "INFO",
  'annotated_by' => ENV['USER'],
  'event_epoch'  =>  options[:time] || Time.now.to_i
}.to_json

puts "data: #{payload}, class: #{payload.class}" if options[:verbose]

url = 'https://event-gateway.stackdriver.com/v1/annotationevent'

response = RestClient.post url, payload, :content_type => :json, :accept => :json, :'x-stackdriver-apikey' => @config['api_key']


if options[:verbose] then
  puts response.code
  puts response.body
end

