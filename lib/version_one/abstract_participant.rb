module VersionOne
class AbstractParticipant < Contributor
  belongs_to :table_of_preference, :class_name => 'Table'
  belongs_to :table
  has_many :preferred_time_slots, :foreign_key => :contributor_id, :autosave => true
end
end
