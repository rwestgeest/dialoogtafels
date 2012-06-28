class Message < ActiveRecord::Base
  has_ancestry
  belongs_to :author, class_name: "Person"
  has_many :message_addressees
  has_many :addressees, :through => :message_addressees, :source => :person
  
  delegate :name, :to => :author, :prefix => :author, :allow_nil => true

  validates_presence_of :body
  validates_presence_of :author
  
  def people_to_notify
    if (parent and addressees.empty?) 
      parent.people_to_notify + [author]
    else
      addressees + [author]
    end
  end

  def parent_subject
    parent && I18n.t('location_comment.reaction_to', :subject => root.subject) || subject
  end

  def create_child(attributes)
    comment = LocationComment.new attributes
    comment.reference = reference
    comment.parent = self
    comment.save
    comment
  end
 
  def set_addressees(addressee_ids = nil)
    return unless addressee_ids
    self.addressees = Person.where(:id => addressee_ids)
  end


  protected
  def notify 
    raise 'define notification in subclass'
  end
end
