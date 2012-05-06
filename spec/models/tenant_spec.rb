require 'spec_helper'
describe Tenant do
  describe 'validation' do
    it { should validate_presence_of :name }
    it { should validate_presence_of :url_code }
    it { should validate_presence_of :site_url }
    it { should validate_presence_of :representative_email }
    it { should validate_presence_of :representative_telephone }
    it { should validate_presence_of :representative_name }
    it { should validate_presence_of :invoice_address }
  end
end
