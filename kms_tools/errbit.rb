require_relative 'config'

# Require the airbrake gem in your App.
# ---------------------------------------------
#
# Ruby - In your Gemfile
# gem 'airbrake', '~> 5.0'
#
# Then add the following to config/initializers/errbit.rb
# -------------------------------------------------------

Airbrake.configure do |config|
    config.host = $airbrake_url
    config.project_id = 1 # required, but any positive integer works
    config.project_key = $airbrake_project_key
end

# this is one way to get the environment your script 
# is running in, you can change out the body of this 
# method with whatever works well for you.
def project_environment
    $environment
end

at_exit do
    # SystemExit and Interrupt are normal exceptions 
    # that terminate the ruby process, ignore them
    if $! and not [SystemExit, Interrupt].include? $!.class
    params = {:argv => ARGV.join(" "), :script => $0}
    environment = project_environment

    if environment == "production"
        Airbrake.notify($!, :parameters => params, 
                            :environment_name => environment)
    end
    end
end
