class Training < ActiveRecord::Base
  include Schedulable

  attr_accessible :name, :location, :max_participants, :description, :start_date, :start_time, :end_date, :end_time

  belongs_to :training_type

  has_many :training_registrations
  has_many :training_invitations, foreign_key: :reference_id
  has_many :attendees, :through => :training_registrations

  validates_presence_of :location
  validates :max_participants, :presence => true, :numericality => true
  validates_presence_of :start_time
  validates_presence_of :start_date
  validates_presence_of :end_time
  validates_presence_of :end_date

  include ScopedModel
  scope_to_tenant

  scope :availables, where("participant_count < max_participants")

  delegate :project, to: :training_type
  delegate :name, to: :training_type
  delegate :description, to: :training_type

  def has_invited?(person)
    invites.include?(person.id)
  end

  def invite_people(people)
    training_registrations.where(:attendee_id => people.collect{|p| p.id}).update_all(:invited => true)
  end

  private
  def invites
    training_registrations.where(:invited => true).map {|registration| registration.attendee_id}
  end
end
