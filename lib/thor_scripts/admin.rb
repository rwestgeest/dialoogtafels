require 'rubygems'
require 'thor'
require 'people_repository'
require 'csv/person_export'

module ThorScripts
  class Admin < Thor
    include FileUtils
    desc "export_people city", "exports the people as csv"
    def export_people(city)
      Tenant.use_host "#{city}.dialoogtafels.nl"
      puts Csv::PersonExport.create(PeopleRepository.new(Tenant.current.active_project)).run(Person.order(:name))
    end
  end
end
