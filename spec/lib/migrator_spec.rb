require 'spec_helper'
require 'migrator'
require 'version_one'

describe Migrator do # not really broken - but slow and in the way - smell
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

  shared_examples_for "a_failing_migration" do

    it { expect { do_migrate }.not_to change(Tenant, :count) }
    it { expect { do_migrate }.not_to change(Project, :count) }
    it { expect { do_migrate }.not_to change(Account, :count) }
    it { expect { do_migrate }.not_to change(Location, :count) }
    it { expect { do_migrate }.not_to change(Person, :count) }
    it { expect { do_migrate }.not_to change(Contributor, :count) }
    it { expect { do_migrate }.not_to change(Training, :count) }
    it { expect { do_migrate }.not_to change(TrainingRegistration, :count) }
    it { expect { do_migrate }.not_to change(ProfileField, :count) }
    it { expect { do_migrate }.not_to change(ProfileFieldValue, :count) }

    it "puts a message with errors on output" do
      do_migrate
      output.should include('name')
    end
  end

  it_should_behave_like "a_failing_migration" do
    before { source_city.update_attribute :name,  '' }
  end

  it_should_behave_like "a_failing_migration" do
    before { source_city.people.first.update_attribute :name,  '' }
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
      its(:organizer_confirmation_text) { should == source_city.organizer_application_confirmation_text }
      its(:conversation_leader_confirmation_text) { should == source_city.leader_application_confirmation_text }
      its(:participant_confirmation_text) { should == source_city.participant_application_confirmation_text }
      its(:invoice_address) { should == source_city.invoice_address }
      its(:site_url) { should == source_city.site_url  }
      its(:host) { should == source_city.url_code + '.dialoogtafels.nl' }

    end

    describe "profile_fields" do
      subject { current_tenant.profile_fields } 
      its (:count)  { should be(5) }
      it "should all be on form" do
        subject.each {|field| field.should be_on_form} 
      end
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
      it "first coordinator has the login name of the first admin" do
        subject.first.name.should == source_city.accounts.admins.first.login
      end
      it "first coordinator has a telephone of 'onbekend;'" do
        subject.first.telephone.should == 'onbekend'
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

    describe "location_todos" do
      subject { LocationTodo }
      its(:count) { should_not == 0 }
      its(:count) { should == source_project.table_todos.count }
      it "'s names match" do
        subject.all.collect {|t| t.name}.sort.should == source_project.table_todos.collect{|t| t.name}.sort
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
      its(:count) { should == source_city.sites.select {|s| s.tables.count > 0 }.size }
    end
    def migratable_source_sites(&block)
      source_city.sites.select {|s| not s.tables.empty? }.each(&block)
    end

    describe "conversations" do 
      it "creates at least one conversation for each location" do
        migratable_source_sites do |site|
          migrator.locations[site.id].should have_at_least(1).conversations
          migrator.locations[site.id].should be_published
        end
      end

      it "creates a conversation for each table with unique start time" do
        migratable_source_sites do |site|
          tables = TableTimeCollection.new(site.tables)
          location = location_for(site)
          location.should have(tables.size).conversations
          tables.each_time do |time|
            conversation = conversation_at(location, time)
            conversation.should_not be_nil
            conversation.number_of_tables.should == tables.at(time).size
            conversation.start_date.should == time.to_date
            conversation.start_time.should == time
            conversation.end_date.should == time.to_date
          end
        end
      end
    end

    def conversation_at(location, time)
      location.conversations.where(:start_time => time).first
    end
    def location_for(site_or_table)
      site_id = site_or_table.is_a?(VersionOne::Site) && site_or_table.id || site_or_table.site_id
      migrator.locations[site_id]
    end

    describe "conversation leaders" do
      subject {ConversationLeader }
      its(:count) { should == source_city.leaders.select { |l| l.table != nil || l.table_of_preference != nil }.size }
      it "registers at the conversation at the appropriate time" do
        source_city.leaders.each do |source_leader| 
          leader = migrator.leaders[source_leader.id]
          table = source_leader.table
          leader.conversation.should == conversation_at(location_for(table), table.time) if table
        end
      end
    end

    describe "conversation_leader_ambitions" do
      pending "will do that later"
    end

    describe "participants" do
      subject { Participant } 
      its(:count) { should == source_city.participants.select { |l| l.table != nil || l.table_of_preference != nil }.size }
      it "registers at the conversatio at the appropriate time" do
        source_city.participants.each do |source_participant| 
          participant = migrator.participants[source_participant.id]
          table = source_participant.table
          participant.conversation.should == conversation_at(location_for(table), table.time) if table
        end
      end
    end

    describe "participant_ambitions" do
      pending "will do that later"
    end

    def type_part_of(string)
      string.split('-').first.strip
    end

    def rest_part_of(string)
      string.split('-')[1..-1].join('-').strip
    end

    describe "trainingtypes" do
      subject { TrainingType } 
      its(:count) { should == source_city.trainings.collect { |t| type_part_of(t.location) }.uniq.size }
    end

    describe "trainings" do
      subject { Training } 
      its (:count) { should == source_city.trainings.count } 
      it "trainings are planned at the correct type" do
        source_city.trainings.each do |training| 
          migrator.trainings[training.id].training_type.should == migrator.training_types[type_part_of(training.location)]
        end
      end
    end

    describe "training" do
      let(:source_training) { source_city.trainings.first }
      subject { migrator.trainings[source_training.id] }
      its (:location) { should_not include(type_part_of(source_training.location)) } 
      its (:location) { should == rest_part_of(source_training.location) } 
    end

    describe "training_tregistrations" do
      subject { TrainingRegistration } 
      its(:count) { should == source_city.trainings.inject(0) {|sum, t| sum + t.training_registrations.count}}
      it "are migrated" do
        source_city.trainings.each do |training|
          migrated_training = migrator.trainings[training.id]
          migrated_training.should have(training.training_registrations.count).training_registrations
          training.training_registrations.each do |registration|
            migrator.people[registration.email].should be_registered_for_training(migrated_training.id)
          end
        end
      end
    end

    describe "output" do
      it "should say so" do
        output.should include('gelukt')
      end
    end

  end
end
