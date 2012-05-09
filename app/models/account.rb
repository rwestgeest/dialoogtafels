require 'bcrypt'

class Account < ActiveRecord::Base
  Maintainer = 'maintainer'
  Coordinator = 'coordinator'
  Organizer = 'organizer'

  belongs_to :tenant
  belongs_to :person

  before_save :encrypt_password

  attr_accessible :email, :password, :password_confirmation, :role
  attr_accessor :password

  # class PasswordValidator < ActiveModel::EachValidator 
  #   def validate_each(record, attribute, value) 
  #     record.errors.add :password, "is not present" unless  value != nil
  #   end
  # end

  # validates :encrypted_password, :password => true, :on => :update
  validates_presence_of :password, :if =>  lambda { !new_record? && !confirmed? }
  validates_presence_of :email
  validates_confirmation_of :password

  class << self 
    def authenticate_by_email_and_password(email, password)
      Account.first
    end
    def maintainer(attributes = {})
      account_with_tenant attributes.merge(:role => Maintainer)
    end
    def coordinator(attributes = {})
      account_with_tenant attributes.merge(:role => Coordinator)
    end
    def organizer(attributes = {})
      account_with_tenant attributes.merge(:role => Organizer)
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

  private 
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
