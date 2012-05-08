class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :authenticate!
  prepend_before_filter :set_current_tenant

  protected
  def authenticate!
    warden.authenticate!
  end
  def set_current_tenant
    Tenant.current = Tenant.find_by_url_code subdomain
  end
  def subdomain
    return 'test' unless request.host.include?('.')
    request.host.split('.').first
  end
end
