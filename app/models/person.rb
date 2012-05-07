class Person < ActiveRecord::Base
  belongs_to :tenant
  has_one :account

  default_scope lambda { where :tenant_id => Tenant.current }

  attr_accessible :name, :email, :telephone, :tenant_id

  delegate :email, :to => :account, :allow_nil => true

  validates:tenant, :presence => true

  def email=(email)
    self.account = Account.new
    self.account.email = email
  end

end
