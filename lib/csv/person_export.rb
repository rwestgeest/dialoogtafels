require 'csv_export'
module Csv

  class PersonExport < Export
    def initialize(column_set)
      @column_set = column_set
    end

    def self.create(people_repository)
      @people_repository = people_repository
      PersonExport.new(PersonExport.person_columns(people_repository))
    end

    def self.person_columns(people_repository)
      column_set = ColumnSet.new(
        Column.new('naam')                  {|person| person.name },
        Column.new('telefoon')              {|person| person.telephone }, 
        Column.new('email')                 {|person| person.email }, 
      )
      people_repository.profile_field_names.each do |field_name| 
        column_set << Column.new(field_name) { |person| person.send("profile_#{field_name}") }
      end
    end
    
    def export(output, people)
      output << column_set.header
      people.each {|person| output << column_set.row(person)} 
    end
    
    def ==(other)
      other.is_a?(self.class) && output == other.output && column_set == other.column_set
    end
    
    protected 
    attr_reader :output, :column_set
  end
end
