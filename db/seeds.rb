# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
Tenant.create name: 'test', 
              url_code: 'test', 
              representative_name: 'Rob Westgeest',
              representative_email: 'rob@qwan.it',
              representative_telephone: '0135421037',
              invoice_address: 'unknown',
              site_url: 'http://www.dialoogtafels.nl',
              info_email: 'rob@qwan.it',
              from_email: 'rob@qwan.it'
