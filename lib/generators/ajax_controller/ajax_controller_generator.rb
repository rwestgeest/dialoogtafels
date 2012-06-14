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

  def create_view_files
    template 'views/_index.html.haml', File.join('app/views', class_path, controller_file_name, '_index.html.haml')
    template 'views/_list_entry.html.haml', File.join('app/views', class_path, controller_file_name, "_#{name}.html.haml")
    template 'views/index.js.erb', File.join('app/views', class_path, controller_file_name, 'index.js.erb')
  end
  hook_for :test_framework, :as => :ajax_scaffold

  # Invoke the helper using the controller name (pluralized)
  hook_for :helper, :as => :scaffold do |invoked|
    invoke invoked, [ controller_name ]
  end

end
