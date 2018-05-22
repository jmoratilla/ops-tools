# coding: utf-8
# Author: Jorge Moratilla Porras
# Description: To split a large CSV file into smaller files

require 'optparse'
require 'pp'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: csv-splitter.rb <input_file> [options]"
  opts.on("-nnumber_of_records", "--name=number_of_records", "Number of records per file") do |n|
    options['number_of_records'] = n
  end
  opts.on("-oNAME", "--output=NAME", "Name of the output file/s") do |f|
    options['output_file'] = f
  end
end.parse!

pp options

# args
input_file = ARGV.shift
output_file = options['output_file'] ? options['output_file'] : 'output'
number_of_records = options['number_of_records'] ? options['number_of_records'].to_i : 10000

output_suffix = 0
headers = nil
buffer = []

File.open(input_file, "r") do |f|
  f.each_with_index do |line,index|
    if index == 0
      headers = line
      next
    elsif index % number_of_records == 0
      output = "#{output_file}-#{output_suffix}.csv"
      puts "Writing file #{output}..."
      File.open(output,"wb") do |out|
        out.puts headers
        out.puts buffer
      end
      buffer = []
      output_suffix += 1
    end
    buffer << line
  end
end
