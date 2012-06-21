class LocationComment < ActiveRecord::Base
  attr_accessible :body, :author, :location_id
  include ScopedModel
  scope_to_tenant
  belongs_to :location
  belongs_to :author, class_name: "Person"
  has_ancestry

  validates_presence_of :body
  validates_presence_of :location
  validates_presence_of :author
  
  def create_child(attributes)
    comment = LocationComment.new attributes
    comment.location = location
    comment.parent = self
    comment.save
    comment
  end
end
