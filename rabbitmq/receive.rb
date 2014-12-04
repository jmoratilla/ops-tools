#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-
require 'bunny'
require 'json'

conn = Bunny.new
conn.start

ch = conn.create_channel

q = ch.queue("feos")

puts " [*] Waiting for messages in #{q.name}. To exit press CTRL+C"
q.subscribe(:block => true) do |delivery_info, properties, body|
	case ENV['debug_level']
	when '1'
		# Mostramos las propiedades
		puts " [#{Time.new}] Showing properties #{properties.inspect}"
		break
	when '2'
		# Mostramos la informacion de entrega del mensaje
		puts " [#{Time.new}] Showing delivery_info #{delivery_info.inspect}"
		break
	when '3'
		# Mostramos todo
		puts " [#{Time.new}] Showing properties #{properties.inspect}"
		puts " [#{Time.new}] Showing delivery_info #{delivery_info.inspect}"
		break
	else
	# No hay debug, no hacemos nada
	end

	# Mostramos el mensaje
	puts " [#{Time.new}] Showing message: #{body}"

	j_msg = JSON.parse(body)

	unless (j_msg.nil?) then
		count = j_msg['id'].to_i
		puts "Working hard for #{count} seconds..."
		sleep count
	end

	# cancel the consumer to exit
	# delivery_info.consumer.cancel
end