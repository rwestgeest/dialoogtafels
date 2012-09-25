class TrainingRegistration < ActiveRecord::Base
  include ScopedModel
  scope_to_tenant
  
  belongs_to :training, counter_cache: :participant_count
  belongs_to :attendee, class_name: 'Person', inverse_of: :training_registrations

  validates_presence_of :training
  validates_presence_of :attendee
  validates_uniqueness_of :attendee_id, scope: :training_id
  attr_accessible :training_id, :attendee_id
end
