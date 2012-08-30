module VersionOne
class PreferredTimeSlot < VersionOneRecord
  belongs_to :contributor
  belongs_to :time_slot
end
end
