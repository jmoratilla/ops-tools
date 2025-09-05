require_relative 'config'
require_relative 'logger'
require_relative 'login'

if ( ARGV.size != 1 )
    puts "Syntax: delete_keys <number>"
    exit 1
end

keys = ARGV[0].to_i

$log.info "Number of keys to delete: #{keys}"

# Listar y guardar las keys
response = HTTParty.get("https://10.0.1.220/api/v1/vault/keys2/?limit=#{keys}", {
    :verify => false,
    :headers => $headers
})
keys = JSON.parse(response.body)['resources']

# Iterar
keys.each do |k|
    $log.info "Deleting key #{k['name']} with id #{k['id']}"

    response =  HTTParty.delete("#{$api_endpoint}/vault/keys2/#{k['id']}", {
        :verify => false,
        :headers => $headers
    })

    $log.debug "Request: #{response.request.uri}"
    $log.debug "Response: #{response.code}"

end
