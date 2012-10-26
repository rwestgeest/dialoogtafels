require 'mailing'

class MailingMessage < Message
  class AddresseeGroupsValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      record.errors.add attribute, (options[:message] || "invalid_groups") unless 
        value.select { |group| not RecipientsBuilder::ValidGroups.has_key?(group.to_sym) }.empty?
    end
  end
  attr_accessible :subject, :body, :author, :reference_id, :parent_id, :parent, :groups, :addressee_groups
  belongs_to :reference, :class_name => 'Project'
  validates_presence_of :reference
  validates :groups, :presence => true, :addressee_groups => true
  validates :subject, :presence => true


  include ScopedModel
  scope_to_tenant

  def groups
    addressee_groups.split(",").map {|group| group.strip} 
  end
  def groups=(value)
    return unless value
    self.addressee_groups = value.join(", ")
  end

end
