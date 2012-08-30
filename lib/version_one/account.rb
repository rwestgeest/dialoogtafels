require 'digest/sha1'

module VersionOne
class Account < VersionOneRecord
  belongs_to :organizing_city
  has_one :organizer
  validates_presence_of :login, :message => "u heeft geen login ingegeven"
  validates_uniqueness_of :login, :message => "deze login naam bestaat al"
  validates_presence_of :raw_password, :message => "u heeft geen wachtwoord ingegeven"
  validates_confirmation_of :changed_password, :message => "de wachtwoorden zijn niet gelijk"
  validates_presence_of :email, :message => "u heeft geen email adres gegeven"
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :message => 'u heeft een ongeldig email adres geven'
  validates_presence_of :role, :message => "u heeft geen role ingegeven"
  # validates_inclusion_of :role, :in => ActionGuard.valid_roles, :message => "u heeft een ongeldige rol ingegeven"
  
  scope :admins, where(:role => 'admin')

  class AuthenticationException < Exception; end
    
  def raw_password
    read_attribute :password
  end
  
  attr_reader :changed_password
  def changed_password=(new_password)
    @changed_password = new_password
    self.password = new_password
  end
  
  def self.authenticate(login, password)
    account = self.find_by_login_and_password(login, self.crypt(password))
    raise AuthenticationException.new("credentials incorrect") unless account
    if account.worker? && account.organizer == nil
      logger.warn("there is no organizer for this worker (#{account.login})")
      raise AuthenticationException.new("there is no organizer for this worker")
    end
    return account
  end

  def self.create_admin_for_city(city, for_email_address = nil)
    generated_password = PasswordGenerator.generate_password
    email = for_email_address || city.representative_email
    login = generate_login(email)
    account = Account.create(:email => email, :role=>:admin, :password => generated_password, :login => login, :organizing_city => city)
    return account unless account.valid?
    account.notify_account_info generated_password 
    return account
  end
  
  def self.generate_for(organizer)
    generated_password = PasswordGenerator.generate_password
    account = Account.new(:email => organizer.email, :role=>:worker, :password => generated_password, :login => generate_login(organizer.email), :organizing_city => organizer.organizing_city)
    account.info = 'login: ' + account.login + ', password: ' + generated_password
    return account
  end

  def self.generate_login(from_email)
    base = from_email[/[^@]+/]
    existing_logins = Account.find(:all).collect{|a| a.login}
    attempt = base
    counter = 0;
    while(existing_logins.include? attempt)
      counter += 1
      attempt = base + counter.to_s
    end
    return attempt
  end
  
  def reset_password
    generated_password = PasswordGenerator.generate_password
    update_attribute :password, generated_password
    notify_account_info generated_password 
  end

  def notify_account_info generated_password 
    self.info = 'login: ' + login + ', password: ' + generated_password 
    Postman.deliver(:new_account_information,self)
  end

  def find_tables(organizing_city, organizer_id = 0, table_todo_id = 0)
    if admin?
      return organizing_city.tables if organizer_id == 0  
      return organizing_city.tables_for_organizer(organizer_id)
    end
    return Table.scoped unless organizer 
    organizer.tables
  end
  
  def unassigned_leaders
    return organizing_city.unassigned_leaders if admin?
    return [] unless organizer
    return organizer.unassigned_leaders
  end
  
  def unassigned_participants
    return organizing_city.unassigned_participants if admin?
    return [] unless organizer
    return organizer.preferred_unassigned_participants
  end
  
  def my_table?(table)
    return true if admin?
    return organizer.my_table?(table)
  end
  
  @@salt = 'west_world'

  def self.crypt(value)
    Digest::SHA1.hexdigest("#{@@salt}--#{value}--")
  end

  def allowed_to_create_tables?
    return true if maintainer?
    return !organizing_city.table_limit_reached?
  end
  
  def admin?
    return role.to_s == 'admin'
  end
  
  def worker?
    return role.to_s == 'worker'
  end
  
  def maintainer?
    return role.to_s == 'maintainer'
  end

  def role
    read_attribute(:role).to_s
  end
  
  def password
    ''
  end

  def password=(new_value)
    write_attribute "password", self.class.crypt(new_value) if new_value && !new_value.empty?
  end

  def info=(value)
    @info = value
  end

  def info
    @info || ''
  end

  def messages_sender
    organizing_city.messages_sender
  end
    
  def info_mail_address
    organizing_city.info_mail_address
  end
  
  def  organizing_city_name
    organizing_city && organizing_city.name || "<geen>"
  end
  
  def from_a_city_if_no_maintainer?
    maintainer? || !organizing_city.nil? 
  end
end
end
