module VersionOne
class OrganizingCity < VersionOneRecord
  MailFormatValidation = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i

  has_many :tables, :include => [:site, {:organizer => :person}]
  has_many :trainings, :include => :training_registrations, :order => 'trainings.time'
  has_many :sites
  has_many :organizers, :through => :people, :order => 'people.name'
  has_one  :first_organizer, :through => :people, :source => :organizers, :order => 'people.name', :class_name => 'Organizer'
  has_many :leaders, :through => :people
  has_many :participants, :through => :people
  has_many :accounts
  has_many :messages, :class_name => 'Message'
  has_many :people
  has_many :contributors, :through => :people
  has_many :time_slots
  has_many :projects
  has_one :current_project, :class_name => 'Project', :foreign_key => :current_for_organizing_city_id, :autosave => true
  
  validates_presence_of :name, :message => "u heeft geen naam ingegeven"
  validates_uniqueness_of :name, :message => "deze naam bestaat al"
  validates_presence_of :url_code, :message => "u heeft geen naam ingegeven"
  validates_uniqueness_of :url_code, :message => "deze naam bestaat al"
  validates_presence_of :site_url, :message => "u heeft geen site url gegeven"
  validates_presence_of :representative_name, :message => "u heeft geen contactpersoon gegeven"
  validates_presence_of :representative_telephone, :message => "u heeft geen contact telefoonnummer gegeven"
  validates_presence_of :invoice_address, :message => "u heeft geen factuuradres gegeven"
  validates_presence_of :table_limit, :message => "u heeft geen tabel maximum gegeven"
  validates_numericality_of :table_limit, :message => "tabel maximum moet een getal zijn"
  validates_presence_of :representative_email, :message => "u heeft geen contact email adres gegeven"
  validates_format_of :representative_email, :with => MailFormatValidation, :message => 'u heeft een ongeldig email adres voor contactpersoon ingegeven'
  validates_presence_of :info_mail_address, :message => "u heeft geen contact email adres gegeven"
  validates_format_of :info_mail_address, :with => MailFormatValidation, :message => 'u heeft een ongeldig email adres voor info adres ingegeven'
  validates_presence_of :messages_sender, :message => "u heeft geen contact email adres gegeven"
  validates_format_of :messages_sender, :with => MailFormatValidation, :message => 'u heeft een ongeldig email adres voor standaard verzender ingegeven'
  validates_presence_of :messages_default_test_email, :message => "u heeft geen contact email adres gegeven"
  validates_format_of :messages_default_test_email, :with => MailFormatValidation, :message => 'u heeft een ongeldig email adres voor standaard test mail adres ingegeven'
  validates_presence_of :max_participants_per_table, :message => "u heeft geen maximum aantal deelnemers per tafel ingegeven"
  validates_presence_of :organizer_application_confirmation_text, :message => "u heeft geen bevestigingsmail opgegeven"
  validates_presence_of :leader_application_confirmation_text, :message => "u heeft geen bevestigingsmail opgegeven"
  validates_presence_of :participant_application_confirmation_text, :message => "u heeft geen bevestigingsmail opgegeven"

  delegate :default_table_start_time, :to => :current_project
  delegate :default_table_start_time=, :to => :current_project
  delegate :table_creation_in_form, :to => :current_project
  delegate :table_creation_in_form=, :to => :current_project
  delegate :auto_commit_table_preference=, :to => :current_project
  delegate :auto_commit_table_preference, :to => :current_project

  def initialize(attributes= {})
    super(attributes)
    self.current_project = Project.new(:organizing_city => self) unless current_project
  end

  def first_table
    tables.find :first
  end

  def table_limit_reached?
    tables.size >= table_limit
  end

  def table_count
    tables.count
  end
  
  def available_organizers
    organizers.find :all, :order => 'name' 
  end
  
  def unassigned_leaders
    leaders.find :all, :conditions => "table_id is null or table_id = '0'", :order => 'name' 
  end
  
  def unassigned_participants
    participants.find :all, :conditions => "table_id is null or table_id = '0'", :order => 'name' 
  end

  def available_sites
    sites.find :all, :order => 'name' 
  end

  def sites_with_tables
    sites.where("not (lattitude = '0' and longitude = '0')").order("sites.name DESC").includes(:tables).select { |site| !site.tables.empty? }
  end

  def publishable_tables
    tables.publishables.order('tables.time, people.name, sites.name')
  end

  def available_tables
    tables.availables.order('sites.name, people.name, tables.time')
  end

  def find_tables
    tables
  end

  def tables_for_organizer(organizer_id)
    tables.where(:'tables.organizer_id' =>  organizer_id)
  end

  def available_trainings(options = {})
    trainings.find(:all,{:conditions => 'max_participants > participant_count'}.merge(options))
  end
  
  def available_tables_for_conversation_leaders
      tables.where("publish_for_leaders='t'").
             where("tables.id not in "+
                                "(SELECT p.table_id FROM contributors p "+
                                    "where p.type = 'Leader' and p.table_id is not null)").
             where("tables.id not in "+
                                "(SELECT p2.table_of_preference_id FROM contributors p2 "+
                                    "where p2.type = 'Leader' and p2.table_of_preference_id is not null)").
             order('tables.time, people.name, sites.name')
  end

  def tables_available_for_leader(leader)
      tables.where("tables.id not in "+
                                "(SELECT p.table_id FROM contributors p "+
                                    "where p.type = 'Leader' and p.table_id is not null and p.id <> ?)", leader.id).
             order('sites.name, tables.name, tables.time')
  end
  
  def all_admins
    accounts.find :all, :conditions => "role = 'admin'"
  end
  
  def notify_application(participant, type_of_application)
    all_admins.each do |admin|
      Postman.deliver(:application_notification, admin, participant, type_of_application)
    end
  end
  
  def notify_application_update(participant, type_of_application)
    all_admins.each do |admin|
      Postman.deliver(:application_update_notification, admin, participant, type_of_application)
    end
  end

  def participant_registration_url
    "http://www.dialoogtafels.nl/registreer/deelnemer/#{url_code}"
  end
  
  def organizer_registration_url
    "http://www.dialoogtafels.nl/registreer/tafelorganisator/#{url_code}"
  end
  
  def conversation_leader_registration_url
    "http://www.dialoogtafels.nl/registreer/gespreksleider/#{url_code}"
  end

  def clean_up!
    tables.destroy_all
    sites.destroy_all
    trainings.each {|t| t.training_registrations.destroy_all }
    trainings.destroy_all
    people.destroy_all
    messages.destroy_all
  end

end
end
