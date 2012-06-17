set :deploy_to, "/var/www/#{application}-gator-preview"
set :domain, "#{user}@preview.#{application}.nl"
set :rails_env, "development"
set :passenger_port, 3033

