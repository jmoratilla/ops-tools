#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-

require 'bunny'
require 'json'

def send(id,msg)
	conn = Bunny.new
	conn.start
	ch = conn.create_channel

	q = ch.queue("feos")
	msg = {
		:id => "#{id}",
		:message => "#{msg}"
	}

	ch.default_exchange.publish(msg.to_json, :routing_key => q.name)
	puts ("[X] Sent message '#{msg}'")
	conn.close
end


if (ARGV.length != 2) then
	puts "Syntax error: command times msg"
	exit 1
end

it = ARGV.shift.to_i

msg = ARGV.shift

it.times do |val|
	send(val,msg)
end