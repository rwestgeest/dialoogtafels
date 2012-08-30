#!/usr/bin/env ruby

require File.expand_path( '../config/environment', File.dirname(__FILE__))
require 'thor'
require 'version_one'
require 'migrator'

module ThorScripts
  class Migrate < Thor
    desc "city", "migrate city from databasefile" 
    def city(city_name, database)
      puts "migrating #{city_name} from #{database} in #{Rails.env}"
      Migrator.new(database).migrate!(city_name)
    end
  end
end


ThorScripts::Migrate.start


