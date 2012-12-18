require 'spec_helper'
require 'csv/person_export'

module Csv
  describe Csv, focus: true do
    let(:people_repository) { mock(PeopleRepository) } 
    let(:first_person) { Person.new :name => "Piet", :telephone => "123123123", :email => "e@mail.com" }
    let(:second_person) { Person.new :name => "Henk", :telephone => "234234234", :email => "other@mail.com" }
    let(:people_to_export) { [ first_person ] }
    let(:exported_data) { export.run(people_to_export) }
    let(:export) { Csv::PersonExport.create people_repository } 

    describe PersonExport do
      subject { exported_data } 

      describe "with one person" do 
        it { should have(2).lines } 
        describe "data" do
          subject { first_data_row_of exported_data } 
          it { should == '"Piet";"123123123";"e@mail.com"' }
        end
      end

      describe "with more persons" do 
        let(:people_to_export) { [first_person, second_person ] }
        it { should have(3).lines }

        describe "data" do 
          subject { second_data_row_of exported_data } 
          it { should == '"Henk";"234234234";"other@mail.com"' }
        end
      end

      describe "header" do
        subject { header_row_of exported_data } 
        it { should == '"naam";"telefoon";"email"' }

        describe "with profile fields" do
          before do
            people_repository.stub(:profile_field_names) { [ "bedrijf" ] }
          end

          it { should include '"bedrijf"' }
        end
      end
    end

    def header_row_of(data)
      rows(data).first
    end

    def first_data_row_of(data)
      rows(data)[1]
    end

    def second_data_row_of(data)
      rows(data)[2]
    end
    def rows(data)
      data.split $/
    end
  end

end



