class Person < ActiveRecord::Base
  include ScopedModel
  scope_to_tenant
  has_one :account
  has_many :contributors

  attr_accessible :name, :email, :telephone, :tenant_id

  delegate :email, :to => :account, :allow_nil => true

  def email=(email)
    self.account = Account.contributor unless account
    self.account.email = email
  end

end
