class Location < ApplicationModel
  include ScopedModel
  scope_to_tenant
  has_attached_file :photo, 
                    :styles => {:medium => "300x300", :thumb => "200x200" },
                    :path => ':rails_root/public/system/tenant/:tenant_id/:class/:attachment/:id/:style/:filename',
                    :url => '/system/tenant/:tenant_id/:class/:attachment/:id/:style/:filename',
                    :default_url => '/assets/locations/thumb_missing.png'

  Paperclip.interpolates(:tenant_id) { |attachment, style|  attachment.instance.tenant_id } 

  belongs_to :project
  belongs_to :organizer
  has_many :conversations, order: "conversations.start_time"
  has_many :conversation_leaders, through: :conversations
  has_many :participants, through: :conversations
  has_many :location_comments


  attr_accessible :name, :address, :postal_code, :city, :organizer_id, :lattitude, :longitude, :published, :photo, :description, :project

  validates_presence_of :name
  validates_presence_of :address
  validates_presence_of :postal_code
  validates_presence_of :city
  validates_presence_of :organizer

  before_validation :associate_to_active_project

  delegate :conversation_length, :to => :project
  delegate :start_date, :to => :project
  delegate :start_time, :to => :project
  delegate :max_participants_per_table, :to => :project

  scope :publisheds, where(:published => true)

  def initialize(attributes = nil, options = {})
    super(attributes, options) 
    self.city ||= Tenant.current && Tenant.current.name 
  end

  def available_conversations_for(person)
    conversations.availables - person.conversations_participating_in
  end

  private 
  def associate_to_active_project
    self.project = tenant.active_project if tenant.present?
  end
end
