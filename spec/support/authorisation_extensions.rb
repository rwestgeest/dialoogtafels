module AuthorisationExtensions
  RSpec::Matchers.define :authorize do |account| 
    chain :to_perform do |action, additional_params|
      @action = action
      @additional_params = additional_params || {}
    end
    match do |guard| 
      guard.authorized?(account, a_request_for(@action, @additional_params))
    end
    def a_request_for(path, additional_params)
      request_params_for(path, additional_params)
    end

    def request_params_for(path, additional_params)
      path, parameters = path.split("?")
      controller, action = path.split('#')
      parameters_hash = Hash[ parameters &&  parameters.split("&").map {|key_value| key_value.split('=').map{|e| e.strip }} || [] ]
      parameters_hash['controller'] = controller
      parameters_hash['action'] = action || 'index'
      parameters_hash.merge! additional_params 
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
