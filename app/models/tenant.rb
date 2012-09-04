class Tenant < ActiveRecord::Base
  has_many :projects, dependent: :destroy
  has_many :accounts, dependent: :destroy

  # just to make sure all is destroyed on destroy
  has_many :people, dependent: :destroy
  has_many :contributors, dependent: :destroy
  has_many :locations, dependent: :destroy
  has_many :organizers, dependent: :destroy
  has_many :conversations, dependent: :destroy
  has_many :conversations, dependent: :destroy
  has_many :accounts, dependent: :destroy
  has_many :location_todos, dependent: :destroy
  has_many :finished_location_todos, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many :profile_fields, dependent: :destroy
  has_many :profile_field_values, dependent: :destroy
  has_many :trainings, dependent: :destroy
  has_many :training_registrations, dependent: :destroy

  has_one  :active_project, :class_name => "Project"
  attr_accessible :from_email, :info_email, :invoice_address, :name, :representative_email, :representative_name, 
                  :representative_telephone, :site_url, :url_code, :host, :top_image, :right_image, :public_style_sheet, :framed_integration,
                  :organizer_confirmation_text, :conversation_leader_confirmation_text, :participant_confirmation_text

  validates :name, :presence => true
  validates :url_code, :presence => true
  validates :site_url, :presence => true
  validates :representative_email, :presence => true
  validates :representative_telephone, :presence => true
  validates :representative_name, :presence => true
  validates :invoice_address, :presence => true

  after_create :create_accoun_and_project

  def coordinator_accounts
    accounts.where :role => Account::Coordinator
  end

  class NullTenant
    def host
      'test.host'
    end
    def from_email
      'noreply@dialoogtafels.nl'
    end
  end

  class << self 
    def current 
      Thread.current[:current_tenant] 
    end
    def current=(tenant)
      Thread.current[:current_tenant] = tenant
    end
    def test
      use_host 'test.host'
    end
    def use_host host
      self.current = Tenant.find_by_host host
    end

    def for(tenant, &block)
      old_tenant = Tenant.current
      begin
        Tenant.current = tenant if tenant
        yield
      ensure
        Tenant.current = old_tenant
      end
    end

    def null
      NullTenant.new
    end
  end
  
  def has_public_style_sheet? 
    public_style_sheet && !public_style_sheet.strip.empty?
  end

  def create_accoun_and_project
    Tenant.for self do
      self.active_project = Project.new(:name => "Dag van de dialoog #{Date.today.year}").for_tenant(self)
      self.accounts << TenantAccount.coordinator(:email => representative_email, :telephone => representative_telephone, :name => representative_name).for_tenant(self)
      save
      update_attribute :active_project_id, active_project.id
    end
  end

end

