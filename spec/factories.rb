FactoryGirl.define do
  factory :tenant do 
    sequence( :name ) { |n| "City_#{n}" }
    sequence( :url_code ) { |n| "city_#{n}" }
    sequence( :representative_name ) { |n| "name_#{n}.com" }
    sequence( :representative_email ) { |n| "mail@city_#{n}.com" }
    sequence( :representative_telephone ) { |n| "phone_#{n}.com" }
    sequence( :site_url ) { |n| "site_url_#{n}" }
    sequence( :info_email ) { |n| "mail@city_#{n}.com" }
    sequence( :from_email ) { |n| "mail@city_#{n}.com" }
    invoice_address "invoice address"
  end
  factory :project, :class => 'Project' do
    name "project"
    association :tenant
  end
end
