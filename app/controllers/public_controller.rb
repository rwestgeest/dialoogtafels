class PublicController < ApplicationController
  layout :determine_layout
  private 
  def determine_layout
    current_tenant.framed_integration && 'framed' || 'public'
  end
end
