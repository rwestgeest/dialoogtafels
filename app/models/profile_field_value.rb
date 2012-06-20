class ProfileFieldValue < ActiveRecord::Base
  attr_accessible :profile_field_id, :person_id, :value, :profile_field
  belongs_to :profile_field
  belongs_to :person
  include ScopedModel
  scope_to_tenant

  validates_presence_of :value
  validates_presence_of :person
  validates_presence_of :profile_field

  def self.null
    ProfileFieldValue.new :value => nil
  end

end
