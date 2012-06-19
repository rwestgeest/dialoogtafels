module AuthorisationExtensions
  RSpec::Matchers.define :authorize do |account| 
    chain :to_perform do |action|
      @action = action
    end
    match do |guard| 
      guard.authorized?(account, a_request_for(@action))
    end
    def a_request_for(path)
      request_params_for(path)
    end

    def request_params_for(path)
      path, parameters = path.split("?")
      controller, action = path.split('#')
      parameters_hash = Hash[ parameters &&  parameters.split("&").map {|key_value| key_value.split('=').map{|e| e.strip }} || [] ]
      parameters_hash['controller'] = controller
      parameters_hash['action'] = action || 'index'
      parameters_hash
    end
  end
  def load_action_guard_from file_path
    guard = ActionGuard::Guard.new 
    guard.load_from_string(File.read(file_path), file_path)
    guard.stub :inspect => 'action_guard'
    guard
  end
end
