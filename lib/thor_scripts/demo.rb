require 'rubygems'
require 'thor'

module ThorScripts 
  class Demo < Thor
    include FileUtils
    desc "rewind", "recreates the demo database in development"
    def rewind
      cp db_path, data_path('production')
      rm_r system_path if File.exists? system_path
      cp_r db_data_path, system_path
    end
    private 
    def db_path
      File.expand_path("db/demo/database.sqlite3", Rails.root)
    end
    def data_path(db) 
      File.expand_path("data/#{db}.sqlite3", Rails.root)
    end
    def system_path
      File.expand_path("public/system/tenant", Rails.root)
    end
    def db_data_path
      File.expand_path("db/demo/data", Rails.root)
    end
  end
end
