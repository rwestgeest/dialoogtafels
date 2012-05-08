class Account < ActiveRecord::Base
  belongs_to :tenant
  belongs_to :person

  attr_accessible :email, :password, :password_confirmation
  def self.authenticate_by_email_and_password(email, password)
    Account.first
  end
end
