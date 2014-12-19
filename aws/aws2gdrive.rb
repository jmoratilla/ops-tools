#!/usr/bin/env ruby
# encoding: UTF-8

require 'json'
require 'google_drive'

# in application
require 'aws-sdk-v1'
require 'aws-sdk'

# Ticking
start_time = Time.now

# Logs in.
# You can also use OAuth. See document of
# GoogleDrive.login_with_oauth for details.
begin
  user = ENV['GDRIVE_USERNAME']
  password = ENV['GDRIVE_PASSWORD']
  session = GoogleDrive.login(user, password)
rescue
  raise ArgumentError, "Login error. Did you set up GDRIVE_USERNAME and GDRIVE_PASSWORD?"
end

# Login into AWS
require_relative File.expand_path("#{ENV['HOME']}/.chef/aws_credentials.rb")
AWS.config(access_key_id:@access_key_id,secret_access_key:@secret_access_key,region:'eu-west-1')

# Accessing EC2 services
ec2 = AWS.ec2 #=> AWS::EC2

t = Time.now.strftime("%Y-%m-%d-%H-%M-%S")

# Create a new spreadsheet and open the first worksheet
ss_title="#{t}-aws-dump"
ss = session.create_spreadsheet(ss_title)
ws = ss.worksheets[0]
ws.title = ss_title

# Header
ws.list.keys = ["id","name","environment","type","virt_type","vpc","subnet","launch_time","state","key_name"]

# Dump
begin
    instances = ec2.instances

    instances.each do |instance|
        ws.list.push({
            "id"            => instance.instance_id,
            "name"          => instance.tags["Name"],
            "environment"   => instance.tags["Env"],
            "type"          => instance.instance_type,
            "virt_type"     => instance.virtualization_type,
            "vpc"           => instance.vpc_id,
            "subnet"        => instance.subnet_id,
            "launch_time"   => instance.launch_time,
            "state"         => instance.methods.include?('state') ? instance.state : "unknown",
            "key_name"      => instance.key_name
        })
    end
rescue Exception => ex
    puts ex.stacktrace
    retry
ensure
    ws.save
    puts "Done. Time elapsed = #{Time.now - start_time} secs"
end


