class TrainingRegistration < ActiveRecord::Base
  include ScopedModel
  scope_to_tenant
  
  belongs_to :training
  belongs_to :attendee, :class_name => 'Person'

  attr_accessible :training_id, :attendee_id
end
