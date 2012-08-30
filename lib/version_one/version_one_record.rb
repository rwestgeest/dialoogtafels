module VersionOne
  class VersionOneRecord < ActiveRecord::Base
    self.abstract_class = true
    def self.store_full_sti_class
      false
    end
  end
end
