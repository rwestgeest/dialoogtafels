set :deploy_to, "/var/www/#{application}-gator-test"
set :domain, "#{user}@test.gator.#{application}.nl"
set :rails_env, "development"
set :passenger_port, 3032

namespace :vlad do
  desc "deploy with tests - only to=test"
  task "deploy:test" => %w{
    update
    update-bundle
    assets
    migrate
    tests
    start
  }

  remote_task "tests", :role => :app do
    in_current_path = "cd #{current_path} && "
    run in_current_path + "RAILS_ENV=#{rails_env} bundle exec rake "
  end

end
