class Tenant < ActiveRecord::Base
  has_many :projects
  has_many :accounts
  attr_accessible :from_email, :info_email, :invoice_address, :name, :representative_email, :representative_name, 
                  :representative_telephone, :site_url, :url_code

  validates :name, :presence => true
  validates :url_code, :presence => true
  validates :site_url, :presence => true
  validates :representative_email, :presence => true
  validates :representative_telephone, :presence => true
  validates :representative_name, :presence => true
  validates :invoice_address, :presence => true

  class << self 
    def current 
      Thread.current[:current] 
    end
    def current=(tenant)
      Thread.current[:current] = tenant
    end
    def create_with_account(attributes)
      tenant = new(attributes)
      begin 
      transaction do 
        tenant.save!
        account = Account.coordinator(:email => tenant.representative_email, :telephone => tenant.representative_telephone, :name => tenant.representative_name)
        account.tenant = tenant
        account.person.tenant = tenant
        account.save!
      end
      rescue ActiveRecord::RecordInvalid 
      end
      return tenant
    end
  end

end

