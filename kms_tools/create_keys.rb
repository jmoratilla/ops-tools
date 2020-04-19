require_relative 'config'
require_relative 'logger'
require_relative 'login'
require_relative 'errbit'

if ( ARGV.size != 2 )
    puts "Syntax: create_keys <from number> <to number>"
    exit 1
end

from = ARGV[0].to_i
to = ARGV[1].to_i

$log.info "Number of keys to generate: #{to - from}"

# Iterar
Benchmark.measure do
    (from..to).each do |k|
        name = "k#{k.to_s.rjust(9,'0')}"
    
        payload = {
            'name': name,
            'usageMask': 4,
            'algorithm': 'aes',
            'size': 128
        }
        
        response =  HTTParty.post("#{$api_endpoint}/vault/keys2/", { 
            :verify => false,
            :body => payload.to_json,
            :headers => $headers
        })
        if (response.code != 201)
            raise "Key: #{name}, response: #{response}"
        end
        $log.info "Created key #{name}"
    end
end