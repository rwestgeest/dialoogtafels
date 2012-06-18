# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
#
unless Tenant.find_by_url_code 'preview'
  Tenant.create name: 'Sassenheim', 
                url_code: 'preview', 
                host: 'preview.dialoogtafels.nl', 
                representative_name: 'Rob Westgeest',
                representative_email: 'rob@qwan.it',
                representative_telephone: '0135421037',
                invoice_address: 'unknown',
                site_url: 'http://www.dialoogtafels.nl',
                info_email: 'rob@qwan.it',
                from_email: 'rob@qwan.it'
end
unless Tenant.find_by_url_code 'gator-test'
  Tenant.create name: 'Sassenheim', 
                url_code: 'gator-test',
                host: 'gator-test.dialoogtafels.nl', 
                representative_name: 'Rob Westgeest',
                representative_email: 'rob@qwan.it',
                representative_telephone: '0135421037',
                invoice_address: 'unknown',
                site_url: 'http://www.dialoogtafels.nl',
                info_email: 'rob@qwan.it',
                from_email: 'rob@qwan.it'
end
unless Tenant.find_by_url_code 'gator-prod'
  Tenant.create name: 'Sassenheim', 
                url_code: 'gator-prod', 
                host: 'gator-prod.dialoogtafels.nl', 
                representative_name: 'Rob Westgeest',
                representative_email: 'rob@qwan.it',
                representative_telephone: '0135421037',
                invoice_address: 'unknown',
                site_url: 'http://www.dialoogtafels.nl',
                info_email: 'rob@qwan.it',
                from_email: 'rob@qwan.it'
end
unless Tenant.find_by_url_code 'test'
  Tenant.create name: 'Sassenheim', 
                url_code: 'test', 
                url_code: 'test.dialoogtafels.nl', 
                representative_name: 'Rob Westgeest',
                representative_email: 'rob@qwan.it',
                representative_telephone: '0135421037',
                invoice_address: 'unknown',
                site_url: 'http://www.dialoogtafels.nl',
                info_email: 'rob@qwan.it',
                from_email: 'rob@qwan.it'
end
unless Account.find_by_email 'admin@example.com'
  Person.create :email => 'admin@example.com'
end
