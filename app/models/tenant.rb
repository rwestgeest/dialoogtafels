class Tenant < ActiveRecord::Base
  has_many :projects
  has_many :accounts
  has_one  :active_project, :class_name => "Project"
  attr_accessible :from_email, :info_email, :invoice_address, :name, :representative_email, :representative_name, 
                  :representative_telephone, :site_url, :url_code

  validates :name, :presence => true
  validates :url_code, :presence => true
  validates :site_url, :presence => true
  validates :representative_email, :presence => true
  validates :representative_telephone, :presence => true
  validates :representative_name, :presence => true
  validates :invoice_address, :presence => true

  after_create :create_accoun_and_project

  class << self 
    def current 
      Thread.current[:current_tenant] 
    end
    def current=(tenant)
      Thread.current[:current_tenant] = tenant
    end
  end

  def create_accoun_and_project
    self.active_project = Project.new(:name => "Dag van de dialoog #{Date.today.year}").for_tenant(self)
    self.accounts << Account.coordinator(:email => representative_email, :telephone => representative_telephone, :name => representative_name).for_tenant(self)
    save
    update_attribute :active_project_id, active_project.id
  end

  def host
    @host || 'test.host'
  end
  def on_host(host)
    @host = host 
    self
  end
end

