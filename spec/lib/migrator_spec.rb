require 'spec_helper'
require 'migrator'
require 'version_one'

describe Migrator do
  attr_reader :migrator
  before(:all) do 
    @migrator = Migrator.new('db/test_old_database.sqlite3')
  end

  let(:current_tenant) { Tenant.current }
  let(:active_project) { current_tenant.active_project } 

  let(:source_city) { VersionOne::OrganizingCity.find_by_url_code('tilburg') }
  let(:source_project) { source_city.current_project }

  let(:output_stream) { StringIO.new }
  def output
    output_stream.string
  end

  def do_migrate
    @migrator.migrate!('tilburg', output_stream)
    Tenant.use_host('tilburg.dialoogtafels.nl')
  end

  after(:each) do
    Tenant.find_by_url_code('tilburg').destroy rescue nil
  end

  describe "when city is invalid" do
    before do 
      source_city.update_attribute :invoice_address,  ''
    end
    
    it "creates nothing" do
      expect { do_migrate }.not_to change(Tenant, :count)
    end

    it "puts a message with errors on output" do
      do_migrate
      output.should include('invoice_address')
    end
  end

  describe "succesfull migration" do
    before(:all)  { do_migrate }
    after(:all) do 
      Tenant.current.destroy
    end

    describe "tenant" do
      subject { current_tenant }
      it { should_not be_nil }
      its( :name ) { should == source_city.name }
      its(:url_code) { should == source_city.url_code }
      its(:representative_name) { should == source_city.representative_name }
      its(:representative_email) { should == source_city.representative_email }
      its(:representative_telephone) { should == source_city.representative_telephone }
      its(:invoice_address) { should == source_city.invoice_address }
      its(:site_url) { should == source_city.site_url  }
      its(:host) { should == source_city.url_code + '.dialoogtafels.nl' }

    end

    describe "profile_fields" do
      subject { current_tenant.profile_fields } 
      its (:count)  { should be(5) }
    end

    describe "active_project" do
      subject { active_project } 
      it { should_not be_nil } 
      its(:name) { should_not == source_project.name } 
      its(:start_time) { should == source_project.default_table_start_time } 
      its(:start_date) { should == source_project.default_table_start_time.to_date } 
      its(:max_participants_per_table) { should == source_city.max_participants_per_table } 
      its(:conversation_length) { should == source_city.table_duration.to_i * 60 }
    end

    describe "coordinators" do
      subject { Account.where(:role => 'coordinator') }
      its( :count) { should == source_city.accounts.admins.count }
      it "'s email addresses match with the original admin email addresses" do
        subject.collect{|a|a.email}.sort.should == source_city.accounts.admins.collect {|a| a.email}.sort
      end
    end

    describe "people" do
      subject { Person }
      its(:count) { should == (source_city.people.collect {|p| p.email} + source_city.accounts.admins.collect {|a| a.email}).uniq.size }
      it "should have an email address for all original people" do
        source_city.people.each do |source_person|
          migrator.should be_account_exists(source_person.email)
          migrator.should be_person_exists(source_person.email)
        end
      end
      it "should have an email address for all original admins" do
        source_city.accounts.admins.each do |source_account|
          migrator.should be_account_exists(source_account.email)
          migrator.should be_person_exists(source_account.email)
        end
      end
    end

    describe "person" do
      let(:first_person) { migrator.people[source_person.email] }
      let(:source_person) { source_city.people.last }
      subject { first_person } 
      it { should_not be_nil }
      its(:name) { should == source_person.name }
      its(:telephone) { should == source_person.telephone }
      its(:email) { should == source_person.email }
      its(:tenant) { should == current_tenant } 
      its(:profile_organisatie) { should == source_person.organization } 
      its(:profile_adres) { should == source_person.address } 
      its(:profile_postcode) { should == source_person.postal_code } 
      its(:profile_woonplaats) { should == source_person.city } 
      its(:profile_opmerkingen) { should == source_person.handicap } 
    end



    describe "organizer" do
      let(:source_organizer) { source_city.organizers.first }
      let(:first_organizer) { Organizer.by_email(source_organizer.email).first}
      subject { first_organizer }
      it { should_not be_nil }
      its(:name) { should == source_organizer.person.name }
      its(:telephone) { should == source_organizer.telephone }
      its(:email) { should == source_organizer.email }
      its(:tenant) { should == current_tenant } 
    end

    describe "organizers" do
      subject { Organizer } 
      its(:count) { should_not == 0}
      its(:count) { should == source_city.organizers.count }

      it "should have an email address for all people" do
        source_city.people.each do |source_person|
          migrator.should be_account_exists(source_person.email)
          migrator.should be_person_exists(source_person.email)
        end
      end
    end
  
    describe "location" do
      let(:first_location) { Location.first }
      let(:source_site) { source_city.sites.first }
      subject { first_location }

      it { should_not be_nil }
      its(:name) { should == source_site.name } 
      its(:address) { should == source_site.address }
      its(:postal_code) { should == source_site.postal_code }
      its(:city) { should == source_site.city }
      its(:lattitude) { should == source_site.lattitude }
      its(:longitude) { should == source_site.longitude }
      its(:organizer) { should == migrator.organizers[source_site.organizer.id] } 
      its(:tenant) { should == current_tenant } 
    end

    describe "locations" do
      subject { Location }
      its(:count) { should == source_city.sites.count }
    end

    describe "output" do
      it "should say so" do
        output.should include('gelukt')
      end
    end

  end
end
