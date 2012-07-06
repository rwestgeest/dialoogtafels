class AddTopAndSideBarToTenant < ActiveRecord::Migration
  def change
    change_table 'tenants' do |t|
      t.string :top_image, :default => '/assets/default_header_background.png'
      t.string :right_image, :default => '/assets/deault_city_name_right.png'
      t.string :public_style_sheet, :default => 'public'
    end
    Tenant.reset_column_information
    Tenant.all.each do |tenant|
      tenant.update_attributes(
        :top_image => '/assets/default_header_background.png',
        :right_image => '/assets/deault_city_name_right.png',
        :public_style_sheet => 'public')
    end
  end
end
