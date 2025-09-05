require 'httparty'
require 'json'

login_payload = {
    username: $username,
    password: $password,
    connection: "local_account",
    grant_type: "password",
    refresh_token_revoke_unused_in: 30
}

$log.debug "Username: #{$username}"
$log.debug "Password: #{$password}"
$log.debug "Endpoint: #{$api_endpoint}"

# Obtener un token de sesión
response = HTTParty.post("#{$api_endpoint}/auth/tokens/", {
    :verify => false,
    :body => login_payload.to_json,
    :headers => {
        'Content-Type' => 'application/json',
        'Accept' => 'application/json'
    }
})
token = JSON.parse(response.body)['jwt']

$headers = {
    'Content-Type' => 'application/json',
    'Accept' => 'application/json',
    'Authorization' => "Bearer #{token}"
}

$log.debug "Token: #{token}"
