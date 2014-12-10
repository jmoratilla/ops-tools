#!/usr/bin/env ruby
# encoding: UTF-8

require 'json'
require 'pp'

# Ticking
start_time = Time.now

aws = JSON.parse(File.read('instances.json'))

# Projects struct
@projects = {
  'silkroad' => [],
  'books'    => [],
  'orpheus'  => [],
  'services' => [],
  'bitbloq'  => [],
  'others'   => []
}

# Total instances
@total_instances = 0

aws['Reservations'].each do |r|
  r['Instances'].each do |i|
    @total_instances = @total_instances + 1

    # Puede tener Name o no, pero siempre tiene Env
    name = i['Tags'].reduce('') do |accumulator,current|
      "#{current['Value']}.#{accumulator}" if current['Key'] =~ /Name|Env/
    end
    useful_data = [i['InstanceId'],name,i['InstanceType']]

    case name
    when /silkroad/
      @projects['silkroad'] << useful_data
    when /books/
      @projects['books'] << useful_data
    when /orpheus/
      @projects['orpheus'] << useful_data
    when /services/
      @projects['services'] << useful_data
    when /bitbloq/
      @projects['bitbloq'] << useful_data
    else
      @projects['others'] << useful_data
    end
  end # instances
end # reservations

# Now, let's aggregate data
def types_sum(instances)
  result = {}
  instances.each do |id,name,type|
    result[type] = []
  end
  instances.each do |id,name,type|
    result[type] << id
  end
  result.each do |type,list|
    result[type] = result[type].length
  end
  result
end

def production(instances)
  result = {}
  begin
    (instances.select {|i| i[1].match(/prod|production/)}).length
  rescue Exception => ex
    pp "Error: #{ex.message}"
  end
end

# Report
report = {}
## Totals
#puts "Total instances: #{@total_instances}"
report['total_instances'] = @total_instances

## Per project
@projects.each do |project,instances|
  report[project] = {
    'summary' => {
      'instances' => instances.length,
      'production' => production(instances),
      'types' => types_sum(instances)
    },
    'instances' => instances
  }
end
puts report.to_json

puts "Done. Time elapsed = #{Time.now - start_time} secs"
