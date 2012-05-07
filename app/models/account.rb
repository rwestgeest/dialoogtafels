class Account < ActiveRecord::Base
  acts_as_authentic do |a| 
    a.validate_password_field = false
  end
  belongs_to :tenant
  belongs_to :person

  attr_accessible :email, :password, :password_confirmation
end
