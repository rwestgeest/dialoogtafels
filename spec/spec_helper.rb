# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'bundler'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'factory_girl_rails'
require 'shoulda-matchers'
require 'ammeter/init'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  Dir[Rails.root.join("spec/shared/**/*.rb")].each {|f| require f}
  config.include ControllerExtensions, :type => :controller
  config.include AuthorisationExtensions, :type => :authorisation
  config.include ScopedModelExtensions
  config.include Factories
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  config.filter_run_excluding :broken => true
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true

end
load_schema = lambda {  
  load "#{Rails.root.to_s}/db/schema.rb" # use db agnostic schema by default  
}
silence_stream(STDOUT, &load_schema)
