require_relative 'config'
require_relative 'logger'
require_relative 'login'
require 'pp'

if ( ARGV.size != 1 )
    puts "Syntax: export_key <name>"
    exit 1
end

name = ARGV[0]
$log.info "Name: #{name}"

# Listar y guardar las keys
response = HTTParty.get("#{$api_endpoint}/vault/keys2/?name=#{name}", {
    :verify => false,
    :headers => $headers
})
keys = JSON.parse(response.body)['resources']

# Iterar
keys.each do |k|
    puts "Exporting key #{k['name']} with id #{k['id']}"

    response = HTTParty.post("https://10.0.1.220/api/v1/vault/keys2/#{k['id']}/export", {
        :verify => false,
        :headers => $headers
    })
    puts "########### KEY      ###########"
    pp JSON.parse(response.body)

    $log.debug "Request: #{response.request.uri}"
    $log.debug "Response: #{response.code}"

end
