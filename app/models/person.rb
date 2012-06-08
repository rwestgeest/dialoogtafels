class Person < ActiveRecord::Base
  EMAIL_REGEXP = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  include ScopedModel
  scope_to_tenant
  has_one :account
  has_many :contributors

  validates :email, :format => EMAIL_REGEXP, :if => :email_present?
  validates :name, :presence => true
  validates :telephone, :presence => true

  attr_accessible :name, :email, :telephone, :tenant_id

  delegate :email, :to => :account, :allow_nil => true

  def email=(email)
    self.account = TenantAccount.contributor unless account
    self.account.email = email
  end

  private 
  def email_present?
    email && !email.empty?
  end
end
