class Account::ResponseSessionsController < ApplicationController

  def show
    @account = Account.find_by_perishable_token(params[:id])
    if @account
      sign_in @account
      redirect_to @account.landing_page
    else
      render status: :not_found
    end
  end

end
