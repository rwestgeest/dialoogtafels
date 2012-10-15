desc "Get production database to development " 
task :get_production do
  sh 'scp deployer@cave:gator-prod/data/production.sqlite3 data/development.sqlite3'
end
desc "Get production log to development " 
task :get_production_log do
  sh "scp deployer@cave:gator-prod/log/production.log log/production#{Date.today.strftime('%Y-%m-%d')}.log"
end

