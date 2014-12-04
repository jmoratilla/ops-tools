#!/usr/bin/env ruby
# encoding: UTF-8

# You need an STACKDRIVER_API_KEY env variable

require 'net/http'
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


message = "#{options[:project]}: #{options[:message]}"

payload = {
  'message' =>  message,
  'level'   =>  options[:level] || "INFO",
  'annotated_by' => ENV['USER'],
  'event_epoch'  =>  options[:time] || Time.now.to_i
}.to_json

puts "data: #{payload}, class: #{payload.class}" if options[:verbose]

url = 'https://event-gateway.stackdriver.com/v1/annotationevent'
uri = URI.parse(url)
request = Net::HTTP::Post.new(uri)
request.content_type = 'application/json'
request['x-stackdriver-apikey'] = ENV['STACKDRIVER_API_KEY']
request.set_form_data(payload)


response = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == 'https') do |http|
  http.request(request)
end

if options[:verbose] then
  puts response.code
  puts response.body
end
