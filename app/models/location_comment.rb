class LocationComment < Message
  attr_accessible :subject, :body, :author, :reference_id, :parent_id, :parent
  after_create :notify

  belongs_to :reference, :class_name => 'Location'
  validates_presence_of :reference

  include ScopedModel
  scope_to_tenant

  protected 
  def notify
    people_to_notify.uniq.each do |addressee|
      Postman.schedule_message_notification(self, addressee)
    end
  end
end
