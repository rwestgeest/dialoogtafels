class ProfileField < ActiveRecord::Base
  abstract_class = true
  attr_accessible :label, :type, :values
end
