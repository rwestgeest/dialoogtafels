
##
# adds profile fields to person
# utilizes method missing and attribute_method? to detect that a profile field is being obtained or changed
# 
module ProfileFields
  def set_profile_attribute(attribute, value)
    return profile_field_value_for(attribute).destroy if value.nil? || value.empty?
    return profile_field_value_for(attribute).update_attribute :value, value if profile_field_values.where('profile_fields.field_name' => attribute).exists?
    profile_field_values << ProfileFieldValue.create(:value => value,
                             :profile_field => ProfileField.find_by_field_name(attribute))
  end

  def get_profile_attribute(attribute)
    profile_field_value_for(attribute).value
  end
  
  def conversation_contributions_for(project)
     contributors.actives.for_project(project.id).where("contributors.type <> 'Organizer'") 
  end

  def attribute_method?(attr_name)
    super || (attr_name.to_s =~ /^profile_(.*)$/ && profile_field_exists?($1))
  end

  def method_missing(method, *args)
    method = method.to_s
    return super unless method =~ /^profile_(.*?)(=|_before_type_cast)?$/ 
    raise NoMethodError.new(method) unless profile_field_exists?($1)
    return self.set_profile_attribute($1, *args) if method =~ /^profile_(.*)=/ 
    return self.get_profile_attribute($1) if method =~ /^profile_(.*)_before_type_cast/ 
    return self.get_profile_attribute($1) if method =~ /^profile_(.*)/ 
  end

  def profile_field_for(profile_field)
    'profile_' + profile_field.label
  end
  private 

  def profile_field_exists?(field)
    ProfileField.find_by_field_name(field)
  end

  def profile_field_value_for(attribute)
    profile_field_values.where('profile_fields.field_name' => attribute).first || ProfileFieldValue.null
  end
end


class Person < ActiveRecord::Base
  EMAIL_REGEXP = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  include ScopedModel
  include ProfileFields

  scope_to_tenant
  has_one :account, inverse_of: :person
  has_many :contributors
  has_many :organizers
  has_many :participants
  has_many :conversation_leaders
  has_many :training_registrations, :foreign_key => :attendee_id, :include => :training, :dependent => :destroy, :autosave => true
  has_many :trainings, :through => :training_registrations
  has_many :profile_field_values, include: :profile_field, inverse_of: :person, autosave: true
  has_many :conversations_participating_in_as_leader, through: :conversation_leaders, source: :conversation
  has_many :conversations_participating_in_as_participant, through: :participants, source: :conversation
  has_many :conversations_participating_in, through: :contributors, source: :conversation

  validates :email, :presence => true, :format => EMAIL_REGEXP
  validates :name, :presence => true
  validates :telephone, :presence => true

  attr_protected :tenant_id

  delegate :email, :to => :account, :allow_nil => true

  scope :conversation_leaders_for, lambda{|project| includes(:contributors).where('contributors.project_id' => project.id, 'contributors.type' => ['ConversationLeader', 'ConversationLeaderAmbition']) }
  scope :conversation_leaders_with_table_for, lambda{|project| includes(:conversation_leaders).where('contributors.project_id' => project.id) }
  scope :conversation_leaders_without_table_for, lambda {|project| joins("LEFT JOIN contributors as c1 on (people.id=c1.person_id AND c1.type='ConversationLeaderAmbition')").
                                                           joins("LEFT JOIN contributors as c2 on (c1.person_id=c2.person_id AND c2.type='ConversationLeader' AND c2.project_id = '#{project.id}')").where('c2.id is null').where('c1.project_id' => project.id) }

  scope :participants_for, lambda{|project| includes(:contributors).where('contributors.project_id' => project.id, 'contributors.type' => ['Participant', 'ParticipantAmbition']) }
  # SELECT "people"."id" AS t0_r0, "people"."name" AS t0_r1, "people"."telephone" AS t0_r2, "people"."project_id" AS t0_r3, "people"."tenant_id" AS t0_r4, "people"."created_at" AS t0_r5, 
  # "people"."updated_at" AS t0_r6, "contributors"."id" AS t1_r0, "contributors"."type" AS t1_r1, "contributors"."project_id" AS t1_r2, "contributors"."tenant_id" AS t1_r3, 
  # "contributors"."person_id" AS t1_r4, "contributors"."created_at" AS t1_r5, "contributors"."updated_at" AS t1_r6, "contributors"."conversation_id" AS t1_r7 
  # FROM "people" 
  # LEFT OUTER JOIN "contributors" ON "contributors"."person_id" = "people"."id" 
  # WHERE "people"."tenant_id" = 1 AND "contributors"."project_id" = 1 AND "contributors"."type" IN ('Participant', 'ParticipantAmbition')
  
  scope :participants_with_table_for, lambda{|project| includes(:contributors).where('contributors.project_id' => project.id, 'contributors.type' => 'Participant') }
  # LEFT OUTER JOIN "contributors" ON "contributors"."person_id" = "people"."id" 
  # WHERE "people"."tenant_id" = 1 AND "contributors"."project_id" = 1 AND "contributors"."type" = 'Participant'
  
  # scope :participants_with_table_for, lambda{|project| includes(:participants).where('contributors.project_id' => project.id) }
  scope :participants_without_table_for, lambda {|project| joins("LEFT JOIN contributors as c1 on (people.id=c1.person_id AND c1.type='ParticipantAmbition')").
                                                           joins("LEFT JOIN contributors as c2 on (c1.person_id=c2.person_id AND c2.type='Participant' AND c2.project_id = '#{project.id}')").where('c2.id is null').where('c1.project_id' => project.id) }
  # SELECT "people".* FROM "people" 
  # LEFT JOIN contributors as c1 on (people.id=c1.person_id AND c1.type='ParticipantAmbition') 
  # LEFT JOIN contributors as c2 on (c1.person_id=c2.person_id AND c2.type='Participant') 
  # WHERE "people"."tenant_id" = 1 AND "c1"."project_id" = 1 AND "c2"."project_id" = 1 AND (c2.id is null)
  
  # scope :participants_without_table_for, lambda { |project| participants_for(project) - participants_with_table_for(project) }
                                                                
  # select c1.person_id, c2.person_id from contributors as c1 left join contributors as c2 on(c1.people_id = c2.people_id) where c1.type=PA and c2.type=P and c2.person_id is null
  # select * from people as p left join contributors as c1 on(people.id = c1.person_id AND c1.type='ParticipantAmbition') left join contributors as c2 on(c1.person_id = c2.person_id and c2.type='Participant') where c2.id is null


  scope :organizers_for, lambda{|project| includes(:organizers).where('contributors.project_id' => project.id)}

  include ModelFilter

  define_filters do
    all 
    organizers :organizers_for
    participants :participants_for
    conversation_leaders :conversation_leaders_for
    free_participants :participants_without_table_for
    free_conversation_leaders :conversation_leaders_without_table_for
  end


  def self.find_by_email email
    includes(:account).where('accounts.email' => email).first
  end

  def replace_training_registrations(training_ids)
    training_registrations.destroy_all
    training_ids.each {|training_id| register_for(training_id) }
  end

  def register_for training
    begin 
      return register_for Training.find(training) unless training.is_a? Training
      trainings << training
      return training
    rescue ActiveRecord::RecordInvalid => e
      return nil
    rescue ActiveRecord::RecordNotFound => e
      return nil
    end
  end

  def registered_for_training?(training_id)
    !training_registrations.select { |training_registration| training_registration.training_id == training_id.to_i }.empty?
  end

  def cancel_registration_for training
    begin 
      training = trainings.find(training)
      trainings.delete training
      return training
    rescue ActiveRecord::RecordNotFound
      return nil
    end
  end

  def conversations_participating_in
    conversations_participating_in_as_leader + conversations_participating_in_as_participant
  end

  def highest_contribution(project)
    contributors.actives.for_project(project).sort { |x,y| x.ordinal_value <=> y.ordinal_value }.first
  end

  def email=(email)
    self.account = TenantAccount.contributor(self) unless account
    self.account.email = email
  end

  private 
  def email_present?
    email && !email.empty?
  end

end
