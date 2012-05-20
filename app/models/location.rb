class Location < ApplicationModel
  include ScopedModel
  scope_to_tenant
  has_attached_file :photo, 
                    :styles => {:medium => "300x300", :thumb => "200x200" },
                    :path => ':rails_root/public/system/:tenant_id/:class/:attachment/:id/:style/:filename',
                    :url => '/system/:tenant_id/:class/:attachment/:id/:style/:filename'

  Paperclip.interpolates(:tenant_id) { |attachment, style|  attachment.instance.tenant_id } 

  belongs_to :project
  belongs_to :organizer
  has_many :conversations

  attr_accessible :name, :address, :postal_code, :city, :organizer_id, :lattitude, :longitude, :published, :photo

  validates_presence_of :name
  validates_presence_of :address
  validates_presence_of :postal_code
  validates_presence_of :city
  validates_presence_of :organizer

  before_validation :associate_to_active_project

  def initialize(attributes = nil, options = {})
    super(attributes, options) 
    self.city ||= Tenant.current && Tenant.current.name 
  end

  private 
  def associate_to_active_project
    self.project = tenant.active_project if tenant.present?
  end
end
