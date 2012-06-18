class Account::PasswordResetsController < ApplicationController
  layout 'sessions'
  def new
    @account = Account.new
  end
  def create
    @account = TenantAccount.find_by_email( params[:account][:email] )
    if (@account) 
      @account.reset!
      redirect_to success_account_password_reset_path
    else
      flash.alert = 'Dit email adres is niet bekend' 
      @account = Account.new
      render :action => :new
    end
  end
  def success

  end
end
