module ControllerExtensions
  def self.included(base) 
    base.extend(ClassMethods)
  end
  def current_account
    @current_account ||= Account.find(session[:current_account_id]) rescue nil
  end
  module ClassMethods
  end
end

