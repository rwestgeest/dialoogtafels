class Tenant < ActiveRecord::Base
  has_many :projects
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
  end

end
