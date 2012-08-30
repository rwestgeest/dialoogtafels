module VersionOne
class TrainingRegistration < VersionOneRecord
    belongs_to :training
    belongs_to :leader, :include => :person
    
    def invite(&block)
      return if invited?
      yield leader if block_given?
      update_attribute :invited, true
    end
    
    def name
      leader.name
    end
    
    def email
      leader.email
    end
    
    def telephone
      leader.telephone
    end

    def diet
      leader.diet
    end

    def handicap
      leader.handicap
    end
end
end
