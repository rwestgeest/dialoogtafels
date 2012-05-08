class LoginController < ApplicationController
  skip_before_filter :authenticate!
  def index
    render :text => 'ech niet'
  end
end
