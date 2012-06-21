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
    desc "to_development", "restores demo back in development to play with data"
    def to_development
      cp db_path, data_path('development')
      rm_r system_path if File.exists? system_path
      cp_r db_data_path, system_path
      Tenant.test
      Tenant.find_by_host('preview.dialoogtafels.nl').update_attribute :host, 'test.host'
      TenantAccount.all.each {|a| a.update_attribute :password, '123123'}
    end
    desc "create", "creates a demo environment from developement" 
    def create
      Tenant.test
      TenantAccount.all.each {|a| a.update_attribute :password, 'dialoog'}
      Tenant.find_by_host('test.host').update_attribute :host, 'preview.dialoogtafels.nl'
      cp data_path('development'), db_path
      rm_r db_data_path if File.exists? db_data_path
      cp_r system_path, db_data_path
      Tenant.find_by_host('preview.dialoogtafels.nl').update_attribute :host, 'test.host'
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
