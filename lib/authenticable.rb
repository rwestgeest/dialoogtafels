require 'bcrypt'
require 'securerandom'

module TokenGenerator 
  def self.generate_token
    SecureRandom.hex(16)
  end
end

module Authenticable
  def self.included(base)
    base.extend ClassMethods

    base.before_save :encrypt_password
  end

  module ClassMethods
    def authenticate_by_email_and_password(email, password)
      account = where("lower(email) = ?", email.downcase).first
      return account if account && 
                        account.confirmed? && 
                        account.authenticate(password)
    end
    def authenticate_by_token(token)
      find_by_authentication_token(token) unless token.nil? || token.empty?
    end
    def on_account_creation method
      after_create method
    end
    def on_account_reset method
      @@reset_hook = Proc.new {|account| account.send(method)}
    end
    def reset_hook
      @@reset_hook ||= Proc.new {|account|  }
    end
  end

  def authenticate(password)
    encrypted_password == BCrypt::Engine.hash_secret(password, password_salt)
  end

  def change_password(attributes)
    self.attributes = attributes
    if !password || password.empty? 
      errors.add(:password, :blank)
      return false
    end

    if password != password_confirmation
      errors.add(:password, :confirmation)
      return false
    end
    update_attributes(attributes)
  end

  def confirm_with_password(attributes)
    begin
      self.attributes = attributes
      if !password || password.empty? 
        errors.add(:password, :blank)
        return false
      end

      if password != password_confirmation
        errors.add(:password, :confirmation)
        return false
      end

      self.confirmed_at = Time.now
      self.reset_at = nil
      save!
      return true
    rescue 
      reload
      return false
    end
  end

  def confirm!
    if has_saved_password? 
      self.confirmed_at = Time.now 
      self.reset_at = nil
      save
    end
    confirmed?
  end

  def reset!
    if (confirmed?)
      generate_authentication_token
      self.reset_at = Time.now
      save!
    end
    do_reset_hook 
  end

  def confirmed?
    confirmed_at != nil
  end

  def reset?
    reset_at != nil
  end

  def generate_authentication_token
    while (true) 
      self.authentication_token = TokenGenerator.generate_token
      return authentication_token if unique_token?(authentication_token)
    end
  end

  private 
  def unique_token? token
    return ! self.class.find_by_authentication_token(token)
  end

  def has_saved_password?
    encrypted_password.present?
  end

  def do_reset_hook
    self.class.reset_hook.call(self)
  end

  def encrypt_password
    if password.present? 
      self.password_salt = ::BCrypt::Engine.generate_salt
      self.encrypted_password = ::BCrypt::Engine.hash_secret(password, password_salt)
    end
  end
end

