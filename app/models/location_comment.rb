class LocationComment < ActiveRecord::Base
  attr_accessible :subject, :body, :author, :location_id, :parent_id, :parent
  include ScopedModel
  scope_to_tenant
  belongs_to :location
  belongs_to :author, class_name: "Person"
  has_ancestry

  validates_presence_of :body
  validates_presence_of :location
  validates_presence_of :author
  
  delegate :name, :to => :author, :prefix => :author, :allow_nil => true
  
  def parent_subject
    parent && I18n.t('location_comment.reaction_to', :subject => root.subject) || subject
  end

  def create_child(attributes)
    comment = LocationComment.new attributes
    comment.location = location
    comment.parent = self
    comment.save
    comment
  end
end
