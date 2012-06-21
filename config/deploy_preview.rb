set :deploy_to, "/var/www/rails/#{application}-gator-preview"
set :domain, "#{user}@preview.#{application}.nl"
set :rails_env, "production"
set :passenger_port, 3033

