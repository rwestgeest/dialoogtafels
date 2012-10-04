class MailingMessage < Message
  attr_accessible :subject, :body, :author, :reference_id, :parent_id, :parent
  belongs_to :reference, :class_name => 'Project'
  validates_presence_of :reference

  include ScopedModel
  scope_to_tenant


end
