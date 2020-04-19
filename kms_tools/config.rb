require 'dotenv/load'
require 'benchmark'
require 'airbrake'

Dotenv.load

$username = ENV.fetch("USERNAME", "admin")
$password = ENV.fetch("PASSWORD", "password")
$api_endpoint  = ENV.fetch("API_ENDPOINT", "https://localhost/api/v1")
$log_level = ENV.fetch("LOG_LEVEL","Logger::WARN")
$airbrake_url = ENV.fetch("AIRBRAKE_URL", "https://localhost:80")
$airbrake_project_key = ENV.fetch("AIBRAKE_PROJECT_KEY", "project_key_here")
$environment = ENV.fetch("RUBY_ENV", "development")
