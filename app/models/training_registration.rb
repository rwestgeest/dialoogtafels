class TrainingRegistration < ActiveRecord::Base
  include ScopedModel
  scope_to_tenant
  
  belongs_to :training
  belongs_to :attendee, :class_name => 'Person'

  validates_presence_of :training
  validates_presence_of :attendee
  validates_uniqueness_of :attendee_id

  attr_accessible :training_id, :attendee_id
end
