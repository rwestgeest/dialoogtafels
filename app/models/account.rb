require 'bcrypt'
require 'securerandom'
module TokenGenerator 
  def self.generate_token
    SecureRandom.hex(16)
  end
end

class Account < ActiveRecord::Base
  include ScopedModel
  scope_to_tenant

  EMAIL_REGEXP = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  Maintainer = 'maintainer'
  Coordinator = 'coordinator'
  Contributor = 'contributor'

  belongs_to :person

  before_save :encrypt_password
  before_create :generate_perishable_token

  attr_accessible :email, :password, :password_confirmation, :role, :name, :telephone
  attr_accessor :password

  # class PasswordValidator < ActiveModel::EachValidator 
  #   def validate_each(record, attribute, value) 
  #     record.errors.add :password, "is not present" unless  value != nil
  #   end
  # end

  # validates :encrypted_password, :password => true, :on => :update
  validates_presence_of :password, :if =>  lambda { !new_record? && !confirmed? }
  validates :email, :presence => true,
                    :uniqueness => true,
                    :format => {:with => EMAIL_REGEXP }
  validates_presence_of :role
  validates_confirmation_of :password

  delegate :name, :to => :person
  delegate :telephone, :to => :person

  def name=(value) 
    self.person = Person.new unless person
    person.name = value
  end

  def telephone=(value) 
    self.person = Person.new unless person
    person.telephone = value
  end

  class << self 
    def authenticate_by_email_and_password(email, password)
      account = Account.find_by_email(email)
      return account if account && 
                        account.confirmed? && 
                        account.encrypted_password == BCrypt::Engine.hash_secret(password, account.password_salt)
    end
    def authenticate_by_token(token)
      Account.find_by_perishable_token(token) unless token.nil? || token.empty?
    end
    def maintainer(attributes = {})
      account_with_tenant attributes.merge(:role => Maintainer)
    end
    def coordinator(attributes = {})
      account_with_tenant attributes.merge(:role => Coordinator)
    end
    def contributor(attributes = {})
      account_with_tenant attributes.merge(:role => Contributor)
    end
    private
    def account_with_tenant(attributes)
      a = Account.new(attributes)
      a.tenant = Tenant.current
      a
    end
  end

  def confirm_with_password(attributes)
    update_attributes(attributes) && confirm!
  end

  def confirm!
    self.confirmed_at = Time.now if has_saved_password? 
    save
  end

  def confirmed?
    confirmed_at != nil
  end

  def generate_perishable_token
    while (true) 
      self.perishable_token = TokenGenerator.generate_token
      return perishable_token if unique_token?(perishable_token)
    end
  end

  private 
  def unique_token? token
    return ! Account.find_by_perishable_token(token)
  end
  def has_saved_password?
    encrypted_password.present?
  end
  def encrypt_password
    if password.present? 
      self.password_salt = ::BCrypt::Engine.generate_salt
      self.encrypted_password = ::BCrypt::Engine.hash_secret(password, password_salt)
    end
  end

end
