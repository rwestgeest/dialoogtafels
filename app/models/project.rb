
class Project < ActiveRecord::Base
  include Schedulable
  include ScopedModel
  scope_to_tenant

  attr_accessible :name, :max_participants_per_table, :conversation_length, 
                  :start_date, :start_time, :organizer_confirmation_text, 
                  :participant_confirmation_text, :conversation_leader_confirmation_text, 
                  :organizer_confirmation_subject, :participant_confirmation_subject, :conversation_leader_confirmation_subject,
                  :grouping_strategy, :obligatory_training_registration,
                  :cc_type, :cc_address_list

  validates :name, :presence => true
  validates :organizer_confirmation_subject, :presence => true
  validates :participant_confirmation_subject, :presence => true
  validates :conversation_leader_confirmation_subject, :presence => true
  validates :max_participants_per_table, 
    :presence => true,
    :numericality => true

  validates :conversation_length, 
    :presence => true,
    :numericality => true

  validates :grouping_strategy,
    :inclusion => { :in => LocationGrouping::ValidStrategies }

  composed_of :mailer, class_name: 'ProjectMailer', mapping: [ 
          %w{cc_type cc_type}, 
          %w{cc_address_list address_list}
  ]

  has_many :location_todos, :inverse_of => :project
  has_many :locations, :order => 'locations.name'
  has_many :mailing_messages, foreign_key: :reference_id
  has_many :organizers
  has_many :conversation_leaders
  has_many :participants

  def initialize(*attrs) 
    super(*attrs)
  end

  def for_tenant(tenant)
    self.tenant = tenant
    return self
  end

  def start_time
    super || Time.now
  end

  def location_count
    locations.count
  end

  def mailer_on(wrapped_mailer)
    mailer.on(wrapped_mailer)
  end

end
