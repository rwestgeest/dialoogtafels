require 'spec_helper'
require 'tmpdir'
require 'generators/ajax_controller/ajax_controller_generator'

describe AjaxControllerGenerator, :focus => true do 
  destination Dir.tmpdir 
  subject { file('app/controllers/posts_controller.rb') }
  before do 
    prepare_destination
    run_generator %w{posts --orm active_record}
  end
  describe 'the controller' do
    it { should exist }
  end
end
