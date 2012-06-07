class Participant < Contributor
  include ScopedModel
  scope_to_tenant

  validates :email, :unique_account => true,
                    :format => {:with => EMAIL_REGEXP }

end
