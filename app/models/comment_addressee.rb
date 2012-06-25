class CommentAddressee < ActiveRecord::Base
  belongs_to :location_comment
  belongs_to :person
end
