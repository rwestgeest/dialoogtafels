class Person < ActiveRecord::Base
  has_one :account

  belongs_to :tenant
  default_scope lambda { where :tenant_id => Tenant.current }
  validates:tenant, :presence => true

  attr_accessible :name, :email, :telephone, :tenant_id

  delegate :email, :to => :account, :allow_nil => true


  def email=(email)
    self.account = Account.new
    self.account.email = email
  end

end
