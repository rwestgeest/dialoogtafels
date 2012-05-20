class Conversation < ActiveRecord::Base
  include ScopedModel
  scope_to_tenant
  belongs_to :location
  attr_accessible :start_at, :end_at, :location_id
end
