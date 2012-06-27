class Message < ActiveRecord::Base
  has_ancestry

  validates_presence_of :body
  validates_presence_of :reference
  validates_presence_of :author
  

end
