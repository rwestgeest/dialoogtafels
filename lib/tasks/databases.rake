desc "Get production database to development " 
task :get_production do
  sh 'scp deployer@cave:gator-prod/data/production.sqlite3 data/development.sqlite3'
end

