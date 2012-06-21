set :deploy_to, "/var/www/rails/#{application}-gator"
set :domain, "#{user}@gator.#{application}.nl"
set :rails_env, "production"
set :passenger_port, 3031

set :migrate_target, :current
desc "Deploy application"
task "deploy" => %w{
    update
    update-bundle
    assets
    start
}
desc "deploy and migrate"
task "deploy:migrate" => %w{
    update
    update-bundle
    assets
    migrate
    start
}

