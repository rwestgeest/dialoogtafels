module ControllerExtensions
  def self.included(base) 
    base.extend(ClassMethods)
  end

  module ClassMethods
    def login_as(account_or_role)
      before(:each) do
        login_as account_or_role
      end
    end
  end

  def login_as(account_or_role)
    return login_as(account_for(account_or_role)) if is_a_role?(account_or_role)
    session[:current_account_id] = account_or_role.id 
  end

  def account_for(role)
    role = role.to_sym
    __accounts[role] || __accounts[role] = __create_and_confirm_account_with_role(role)
  end

  private
  def __accounts
    @__accounts ||= {}
  end
  def __create_and_confirm_account_with_role(role)
    if ( role == :organizer )
      account = FactoryGirl.create(role).account
    else
      account = FactoryGirl.create(:"#{role}_account")
    end
    account.confirm!
    return account
  end
  def is_a_role?(account_or_role)
    account_or_role.is_a?(Symbol) || account_or_role.is_a?(String)
  end

  def current_account
    @current_account ||= Account.find(session[:current_account_id]) rescue nil
  end

end

