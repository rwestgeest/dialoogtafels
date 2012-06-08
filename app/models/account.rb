require 'authenticable'

class Account < ActiveRecord::Base
  include Authenticable
  on_account_creation :send_confirmation_message
  on_account_reset :send_reset_message

  Maintainer = 'maintainer'
  Coordinator = 'coordinator'
  Contributor = 'contributor'
  EMAIL_REGEXP = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i


  belongs_to :person
  before_create :generate_authentication_token

  attr_accessible :email, :password, :password_confirmation, :role, :name, :telephone
  attr_accessor :password

  validates :email, :presence => true,
                    :uniqueness => true,
                    :format => {:with => EMAIL_REGEXP }
  validates_presence_of :role
  validates_confirmation_of :password

  delegate :name, :to => :person
  delegate :telephone, :to => :person

  def for_tenant(tenant)
    self.tenant = tenant
    self.person = Person.new unless person
    self.person.tenant = tenant
    return self
  end
  
  def name=(value) 
    self.person = Person.new unless person
    person.name = value
  end

  def telephone=(value) 
    self.person = Person.new unless person
    person.telephone = value
  end

  def send_confirmation_message
    Postman.deliver(:account_welcome, self)
  end

  def send_reset_message
    Postman.deliver(:account_reset, self)
  end

  def active_contribution
    contribution_to(tenant.active_project)
  end

  def contribution_to(project)
    person.contributors.where(:project_id => project).first
  end

  def landing_page
    return '/account/password/edit' if !confirmed? || reset?
    if role == Account::Contributor 
      return '/organizer/locations' if active_contribution.is_a? Organizer
      return '/contributor/registration' 
    end
    return '/admin/tenants' if role == Account::Maintainer
    '/'
  end

end
