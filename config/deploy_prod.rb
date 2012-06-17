set :deploy_to, "/var/www/rails/#{application}-gator"
set :domain, "#{user}@gator.#{application}.nl"
set :rails_env, "production"
set :passenger_port, 3031

