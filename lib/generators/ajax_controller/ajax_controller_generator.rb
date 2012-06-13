require 'rails/generators'
require 'rails/generators/resource_helpers'
class AjaxControllerGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)
  include Rails::Generators::ResourceHelpers

  check_class_collision :suffix => "Controller"

  class_option :orm, :banner => "NAME", :type => :string, :required => true,
    :desc => "ORM to generate the controller for"

  def create_controller_files
    aa= File.join('app/controllers', class_path, "#{controller_file_name}_controller.rb")
    template 'controller.rb', aa
  end

  hook_for :template_engine, :test_framework, :as => :ajax_scaffold

  # Invoke the helper using the controller name (pluralized)
  hook_for :helper, :as => :scaffold do |invoked|
    invoke invoked, [ controller_name ]
  end

end
