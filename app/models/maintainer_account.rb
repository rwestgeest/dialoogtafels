class MaintainerAccount < Account
  class << self 
    def maintainer(attributes = {})
      new attributes.merge(:role => Account::Maintainer)
    end
  end
  def tenant
    @tenant ||= Tenant.null
  end
end
