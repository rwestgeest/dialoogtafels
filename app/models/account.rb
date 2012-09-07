require 'authenticable'

class Account < ActiveRecord::Base
  include Authenticable
  on_account_reset :send_reset_message

  Maintainer = 'maintainer'
  Coordinator = 'coordinator'
  Contributor = 'contributor'
  ConversationLeader = ::ConversationLeader.to_s.underscore
  Participant = ::Participant.to_s.underscore
  Organizer = ::Organizer.to_s.underscore

  EMAIL_REGEXP = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i


  belongs_to :person, inverse_of: :account
  before_create :generate_authentication_token

  attr_accessible :email, :password, :password_confirmation, :role, :name, :telephone
  attr_accessor :password

  validates :email, :presence => true,
                    :uniqueness => {:scope => :tenant_id },
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

  def highest_contribution
    @highest_contribution ||= highest_contribution_to(tenant.active_project)
  end

  def highest_contribution_to(project)
    person.highest_contribution(project)
  end

  def role
    unless @role_value 
      @role_value = super
      @role_value = highest_contribution.class.to_s.underscore if @role_value == Contributor && highest_contribution
    end
    @role_value
  end

  def landing_page
    return '/account/password/edit' if !confirmed? || reset?
    return '/city/locations' if role == Account::Coordinator
    return '/organizer/locations' if role == Account::Organizer
    return '/contributor/registration'if role == Account::ConversationLeader || role == Account::Participant 
    return '/admin/tenants' if role == Account::Maintainer
    '/'
  end

end
