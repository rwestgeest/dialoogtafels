class LocationComment < ActiveRecord::Base
  attr_accessible :subject, :body, :author, :location_id, :parent_id, :parent
  after_create :notify

  include ScopedModel
  scope_to_tenant
  belongs_to :location
  belongs_to :author, class_name: "Person"
  has_many :comment_addressees
  has_many :addressees, :through => :comment_addressees, :source => :person
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
 
  def add_addressees(*addressee_ids)
    self.addressees = addressee_ids.collect { |addressee_id| Person.find(addressee_id) }
  end

  private 
  def notify
    (addressees + [ author ]).uniq.each do |addressee|
      Postman.schedule_message_notification(self, addressee)
    end
  end
end
