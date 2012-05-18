class Contributor < ApplicationModel
  belongs_to :person 
  has_one :account, :through => :person
end
