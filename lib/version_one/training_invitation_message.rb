module VersionOne

  class TrainingInvitationMessage < Message
    class Instance < VersionOne::Message::Instance
      attr_reader :leader
      def initialize(message, leader)
        super(message)
        @leader = leader
      end
      
      def recepients
        @leader.email
      end
      
      def body 
        commencement + " " + recepient_name + $/ + $/ +
        super + $/ + $/ +
        "training details:" + $/ + $/ +
        message.training_details
      end
      
      def recepient_name
        @leader && 
            @leader.name ||
              "<hier komt de naam van de gespreksleider>"
            
      end
      
      def ==(other)
        return false unless other.is_a?(Instance)
        return message == other.message && leader == other.leader
      end
      
      def to_s
        "table summary message instance for message #{message.id} and leader #{leader}"
      end
      
      alias_method :inspect, :to_s
    end

    class TestInstance < Instance
      def recepients
        message.test_recepient
      end
      def ==(other)
        return false unless other.is_a?(TestInstance)
        return message == other.message && leader == other.leader
      end
    end 

    class RecepientList 
      def human_representation
        'Trainees'
      end
    end
   
    belongs_to :training

    def self.for_training(training, attrs = {})
      attrs = attrs.symbolize_keys
      attrs[:training] = training
      attrs[:organizing_city] = training.organizing_city
      attrs[:subject] = invitation_subject_for_training(training)
      attrs[:status] = Verified
      new(attrs)
    end
    
    def self.invitation_subject_for_training(training)
      "Uitnodiging voor dialoog training d.d. #{training.readable_date}"
    end
    
    def message_type
      subject
    end
    
    def template_name
      'training_invitation_message'
    end

    def recepient_list
      @recepient_list ||= RecepientList.new
    end
    
    def training_details
      training.details
    end
    
    def instances(&block)
      training.training_registrations.each do |registration| 
        registration.invite do |leader|
          yield(Instance.new(self, leader)) if leader && block_given? 
        end
      end
      return nil
    end
    
    def create_test_instance
      TestInstance.new(self, training.first_leader)
    end
  end
end
