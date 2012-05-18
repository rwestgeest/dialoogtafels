module Factories
  FactoryGirl.define do
    sequence(:email) { |n| "some_address_#{n}@example.com" }
    factory :tenant do 
      sequence( :name ) { |n| "City_#{n}" }
      sequence( :url_code ) { |n| "city_#{n}" }
      sequence( :representative_name ) { |n| "name_#{n}.com" }
      sequence( :representative_email ) { |n| "mail_#{n}@city.com" }
      sequence( :representative_telephone ) { |n| "phone_#{n}.com" }
      sequence( :site_url ) { |n| "site_url_#{n}" }
      sequence( :info_email ) { |n| "mail@city_#{n}.com" }
      sequence( :from_email ) { |n| "mail@city_#{n}.com" }
      invoice_address "invoice address"
    end

    factory :location do 
      sequence( :name ) { |n| "location_#{n}" }
      address "location_address"
      postal_code "AAAA 12"
      city "Location city"
      association :organizer
    end

    factory :project, :class => 'Project' do
      name "project"
    end

    factory :person do
      sequence( :email ) { |n| "mail_#{n}@person.com" }
      sequence( :name ) { |n| "person_#{n}" }
      sequence( :telephone ) { |n| "telephone_#{n}" }
    end

    factory :organizer  do
      sequence( :email ) { |n| "mail_#{n}@organizer.com" }
      sequence( :name ) { |n| "organizer_#{n}" }
      sequence( :telephone ) { |n| "telephone#{n}" }
    end

    factory :maintainer_account, :class => Account, :aliases => [:account] do
      sequence( :email ) { |n| "maintainer_account_#{n}@mail.com" }
      role Account::Maintainer
      association :person , :email => nil
      factory :confirmed_account do
        password 'secret'
        password_confirmation 'secret'
        after_create do |account|
          account.confirm!
        end
      end

    end

    factory :coordinator_account, :class => Account do
      sequence( :email ) { |n| "coordinator_account_#{n}@mail.com" }
      role Account::Coordinator
      sequence( :name ) { |n| "person_#{n}" }
      sequence( :telephone ) { |n| "telephone_#{n}" }
    end

    factory :contributor_account, :class => Account do
      sequence( :email ) { |n| "contributor_account_#{n}@mail.com" }
      role Account::Contributor
      association :person, :email => nil
    end
  end
end
