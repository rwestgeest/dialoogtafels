
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
  has_many :conversations, dependent: :destroy, order: "conversations.start_time", inverse_of: :location
  has_many :conversation_leaders, through: :conversations
  has_many :participants, through: :conversations
  has_many :location_comments, foreign_key: :reference_id
  has_many :finished_location_todos, :inverse_of => :location
  has_many :todos, through: :project, source: :location_todos


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

  scope :publisheds, where(:published => true).order('locations.name')
  scope :availables_for_participants, 
        publisheds.
        includes(:conversations, :project).
        where('conversations.id is not null').
        where('conversations.participant_count < projects.max_participants_per_table')
  scope :publisheds_for_conversation_leaders, 
        publisheds.
        includes(:conversations, :project).
        where('conversations.id is not null').
        where('conversations.conversation_leader_count < conversations.number_of_tables')
  

  def initialize(attributes = nil, options = {})
    super(attributes, options) 
    self.city ||= Tenant.current && Tenant.current.name 
  end

  def number_of_tables
    @number_of_tables ||= conversations.inject(0) { |sum, conversation| sum + conversation.number_of_tables }
  end

  def full? 
    conversations.fulls.count == conversations.count && conversations.count > 0
  end

  def todo_progress
    return 100 if project.location_todos.empty?
    100 * finished_location_todos.count / project.location_todos.count
  end

  def tick_done(todo_id)
    begin 
      todo_to_tick = project.location_todos.find(todo_id)
      return if todo_to_tick.done_for_location?(self)
      FinishedLocationTodo.create(:location => self, :location_todo => todo_to_tick)
    rescue ActiveRecord::RecordNotFound
      # this is ok
    end
  end

  def tick_undone(todo_id)
    finished_todo = FinishedLocationTodo.where(:location_todo_id => todo_id, :location_id => self.id).first
    finished_todo && finished_todo.destroy
  end

  def available_conversations_for(person)
    conversations.availables - person.conversations_participating_in
  end

  private 
  def associate_to_active_project
    self.project = tenant.active_project if tenant.present?
  end
end
