#Rails.configuration.middleware.use RailsWarden::Manager do |manager|
  #manager.default_strategies :my_strategy
  #manager.failure_app = LoginController.new
#end
Rails.configuration.middleware.use Warden::Manager do |manager| 
  manager.default_strategies :my_strategy
  manager.failure_app = lambda { |env| LoginController.action(:index).call(env) }
end

# Setup Session 
class Warden::SessionSerializer
  def serialize(record)
    [record.class.name, record.id]
  end

  def deserialize(keys)
    klass, id = keys
    klass.find(:first, :conditions => { :id => id })
  end
end

# Declare your strategies here
Warden::Strategies.add(:my_strategy) do
  #def valid?
    #params[:email] || params[:password]
  #end
  def authenticate!
    account = Account.authenticate_by_email_and_password('email','password')
    account && success!(account) || fail!('mislukt')
  end
end
