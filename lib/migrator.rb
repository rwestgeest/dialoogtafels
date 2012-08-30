class Migrator 
  attr_reader :organizers, :people, :accounts

  def initialize(filename)
    @filename = filename
    @organizers = {}
    @people = {}
    @accounts = {} 
    prepare_database
  end

  attr_reader :output

  def migrate!(url_code, output = $STDOUT)
    @output = output
    organizing_city = VersionOne::OrganizingCity.find_by_url_code(url_code)
    begin 
      migrate_organizing_city(organizing_city.accounts.admins.first.email,name: organizing_city.name, 
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


      organizing_city.people.each do |source_person|

        person = migrate_person(source_person, 
                           name: source_person.name,
                           telephone: source_person.telephone,
                           email: source_person.email)
        person.update_attributes profile_adres: source_person.address
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
                        longitude: site.longitude )
      end

    rescue ActiveRecord::RecordInvalid  => e
      output.puts e.record.errors.full_messages
      output.puts "Migratie is gefaald!"
      return
    end
    output << 'Migratie gelukt'
  end

  def migrate_organizing_city(first_administrator_email, attributes)
    tenant = migrate_thing "city", attributes do 
      Tenant.create!(attributes.merge(representative_email: first_administrator_email))
    end
    tenant.update_attribute :representative_email, attributes[:representative_email]
    Tenant.current = tenant
    add_person Person.first.email, Person.first

    ProfileTextField.create!(field_name: 'organisatie', label: 'Organisatie')
    ProfileStringField.create!(field_name: 'adres', label: 'Adres')
    ProfileStringField.create!(field_name: 'postcode', label: 'Postcode')
    ProfileStringField.create!(field_name: 'woonplaats', label: 'Wooplaats')
    ProfileTextField.create!(field_name: 'opmerkingen', label: 'Bijzonderheden')
  end

  def migrate_project(attributes)
    migrate_thing "project", attributes do
      Tenant.current.active_project.update_attributes(attributes)
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

  def migrate_organizer(source_organizer, attributes)
    add_organizer source_organizer.id, migrate_thing( "organizer", attributes) { 
      Organizer.create!(:person => people[source_organizer.email])
    }
  end

  def migrate_location(source_site, attributes)
    migrate_thing "location", attributes do 
      assign_attributes(Location.new, attributes).save!
    end
  end

  def migrate_thing(what, attributes = nil)
    begin
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

  def add_person(email, person)
    people[email] = person
    accounts[email] = person.account
    person
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

