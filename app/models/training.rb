class Training < ActiveRecord::Base
  include Schedulable

  attr_accessible :name, :location, :max_participants, :description, :start_date, :start_time, :end_date, :end_time
  belongs_to :project
  has_many :training_registrations
  has_many :training_invitations, foreign_key: :reference_id
  has_many :attendees, :through => :training_registrations

  before_validation :associate_to_active_project
  validates_presence_of :name
  validates_presence_of :location
  validates :max_participants, :presence => true, :numericality => true
  validates_presence_of :start_time
  validates_presence_of :start_date
  validates_presence_of :end_time
  validates_presence_of :end_date


  include ScopedModel
  scope_to_tenant

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
  def associate_to_active_project
    self.project = tenant.active_project if tenant.present?
  end

end
