class TableTimeCollection
  def initialize(tables)
    @tables = {}
    tables.each { |table| self << table }
  end
  def << (table)
    at(table.time) << table
  end
  def at(time)
    @tables[time] ||= []
  end
  def size
    @tables.size
  end
  def each_time(&block)
    @tables.keys.each &block
  end
end

class Migrator 
  attr_reader :organizers, :people, :accounts, :locations, :leaders, :participants, :training_types, :trainings

  def initialize(filename)
    @filename = filename
    @organizers = {}
    @people = {}
    @accounts = {} 
    @locations = {}
    @leaders = {}
    @participants = {}
    @training_types = {}
    @trainings = {}
    prepare_database
  end

  attr_reader :output

  def migrate!(url_code, output = $stdout)
    @output = output
    organizing_city = VersionOne::OrganizingCity.find_by_url_code(url_code)
    begin 
    Tenant.transaction do
      migrate_organizing_city(organizing_city.accounts.admins.first,name: organizing_city.name, 
                     url_code: organizing_city.url_code,
                     site_url: organizing_city.site_url,
                     invoice_address: organizing_city.invoice_address,
                     representative_name: organizing_city.representative_name,
                     representative_email: organizing_city.representative_email,
                     representative_telephone: organizing_city.representative_telephone,
                     info_email: organizing_city.info_mail_address,
                     from_email: organizing_city.info_mail_address,
                     host: "#{organizing_city.url_code}.dialoogtafels.nl")


      migrate_project(
                    start_date:  organizing_city.current_project.default_table_start_time,
                    start_time:  organizing_city.current_project.default_table_start_time,
                    max_participants_per_table: organizing_city.max_participants_per_table,
                    conversation_length: organizing_city.table_duration.to_i * 60)

      organizing_city.current_project.table_todos.each do |table_todo|
        migrate_todo(
          name: table_todo.name 
        )
      end


      organizing_city.people.each do |source_person|

        person = migrate_person(source_person, 
                           name: source_person.name,
                           telephone: source_person.telephone,
                           email: source_person.email)
        person.update_attributes profile_adres: source_person.address,
                                 profile_organisatie: source_person.organization,
                                 profile_postcode: source_person.postal_code,
                                 profile_woonplaats: source_person.city,
                                 profile_opmerkingen: source_person.handicap
      end

      organizing_city.accounts.admins.each do |source_account|
        migrate_admin(source_account)
      end

      organizing_city.organizers.each do |source_organizer|
        migrate_organizer( source_organizer,
                           name: source_organizer.name,
                           telephone: source_organizer.telephone,
                           email: source_organizer.email)
      end

      organizing_city.sites.each do |site| 
        migrate_location( site, 
                        organizer: organizers[site.organizer_id],
                        name: site.name,
                        address: site.address,
                        postal_code: site.postal_code,
                        city: site.city,
                        lattitude: site.lattitude,
                        longitude: site.longitude,
                        published: true)
      end

      organizing_city.leaders.each do |source_leader| 
        migrate_leader( source_leader )
      end

      organizing_city.participants.each do |source_participant| 
        migrate_participant( source_participant )
      end

      migrate_trainings(organizing_city.trainings)
    end
    rescue ActiveRecord::RecordInvalid  => e
      output.puts e.record.errors.full_messages
      output.puts "Migratie is gefaald!"
      return
    end
    output << 'Migratie gelukt'
  end

  def migrate_organizing_city(first_administrator, attributes)
    tenant = migrate_thing "city", attributes do 
      Tenant.create!(attributes.merge(representative_email: first_administrator.email,
                                      representative_name: first_administrator.login,
                                      representative_telephone: 'onbekend'))
    end
    tenant.update_attribute :representative_email, attributes[:representative_email]
    tenant.update_attribute :representative_name, attributes[:representative_name]
    tenant.update_attribute :representative_telephone, attributes[:representative_telephone]
    Tenant.current = tenant
    add_person Person.first.email, Person.first

    ProfileTextField.create!(field_name: 'organisatie', label: 'Organisatie', on_form: true)
    ProfileStringField.create!(field_name: 'adres', label: 'Adres', on_form: true)
    ProfileStringField.create!(field_name: 'postcode', label: 'Postcode', on_form: true)
    ProfileStringField.create!(field_name: 'woonplaats', label: 'Wooplaats', on_form: true)
    ProfileTextField.create!(field_name: 'opmerkingen', label: 'Bijzonderheden', on_form: true)
  end

  def migrate_project(attributes)
    migrate_thing "project", attributes do
      Tenant.current.active_project.update_attributes(attributes)
    end
  end

  def migrate_todo(attributes)
    migrate_thing "todo", attributes do
      LocationTodo.create(attributes)
    end
  end

  def migrate_admin(source_account) 
    if !account_exists?(source_account.email)
      person = add_person( source_account.email, migrate_thing("person for account", nil) { 
          Person.create(:email => source_account.email, :name => source_account.login, :telephone => "onbekend")
        })
    end
    accounts[source_account.email].update_attribute :role, Account::Coordinator
  end

  def migrate_person(source_person, attributes)
    return people[source_person.email] if person_exists?(source_person.email) 

    add_person( source_person.email, migrate_thing("person", attributes) { 
      Person.create!(attributes)
    })
  end

  def migrate_leader(source_leader)
    table = source_leader.table || source_leader.table_of_preference
    return unless table
    add_leader(source_leader.id, migrate_thing("conversation_leader") {
      ConversationLeader.create!(person: people[source_leader.email], 
                                 conversation: locations[table.site_id].conversations.where(start_time: table.time).first)
    })
  end

  def migrate_participant(source_participant)
    table = source_participant.table || source_participant.table_of_preference
    return unless table
    add_participant(source_participant.id, migrate_thing("conversation_participant") {
      Participant.create!(person: people[source_participant.email], 
                          conversation: locations[table.site_id].conversations.where(start_time: table.time).first)
    })
  end

  def migrate_organizer(source_organizer, attributes)
    add_organizer source_organizer.id, migrate_thing( "organizer", attributes) { 
      Organizer.create!(:person => people[source_organizer.email])
    }
  end

  def migrate_location(source_site, attributes)
    return if source_site.tables.empty?
    add_location source_site.id, migrate_thing("location", attributes) {
      save(assign_attributes(Location.new, attributes))
    }
    migrate_conversations(source_site)
  end

  def create_name_and_location(location)
    if location.include? '-'
      tokens = location.split('-')
      return tokens.first.strip, tokens[1..-1].join('-').strip
    else
      return "Gespreksleiderstraining", location
    end
  end
  def migrate_trainings(source_trainings) 
    source_trainings.each do |training| 
      training_type_name, location_name = create_name_and_location(training.location)

      training_type = create_training_type(training_type_name)
      planned_training = add_training(training.id, training_type.trainings.create!(
        start_time: training.time,
        start_date: training.time.to_date,
        end_date: (training.time + 2.hours).to_date,
        end_time: training.time + 2.hours,
        max_participants: training.max_participants,
        location: location_name
      ))
      training.training_registrations.each do |registration|
        people[registration.email].register_for(planned_training)
      end
    end
  end

  def create_training_type(name)
    unless @training_types[name]
      @training_types[name] = TrainingType.create!(name: name)
    end
    @training_types[name]
  end

  def migrate_conversations(source_site)
    tables = TableTimeCollection.new(source_site.tables)
    tables.each_time do |time|
      end_time = tables.at(time).first.ends_at
      Conversation.create! location: locations[source_site.id],
                           start_date: time.to_date, 
                           start_time: time,
                           end_time: end_time,
                           end_date: time.to_date,
                           number_of_tables: tables.at(time).size
    end
  end

  def migrate_thing(what, attributes = nil)
    begin
      output.puts "migrating #{what}"
      yield
    rescue ActiveRecord::RecordInvalid  => e
      output.puts "error while migrating #{what} with attributes #{attributes.inspect}" 
      raise e
    end
  end

  def assign_attributes(record, attributes)
    attributes.each { |key, value| record.send("#{key}=", value) }
    return record
  end

  def save(record)
    record.save!
    record
  end

  def add_organizer(key, organizer)
    organizers[key] = organizer
    organizer
  end

  def add_leader(key, leader)
    leaders[key] = leader
    leader
  end

  def add_participant(key, participant)
    participants[key] = participant
    participant
  end

  def add_person(email, person)
    people[email] = person
    accounts[email] = person.account
    person
  end

  def add_location(site_id, location)
    locations[site_id] = location
    location
  end

  def add_training(training_id, training)
    trainings[training_id] = training
    training
  end

  def person_exists?(email)
    !people[email].nil?
  end

  def account_exists?(email)
    !accounts[email].nil?
  end

  def prepare_database
    return if @database_prepared
    VersionOne.load_database(@filename) 
    @database_prepared = true
  end
end

