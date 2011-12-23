Warden::Manager.serialize_into_session{|user| user.id }
Warden::Manager.serialize_from_session{|id| User.get(id) }
 
Warden::Manager.before_failure do |env,opts|
  env['REQUEST_METHOD'] = "POST"
end
 
Warden::Strategies.add(:password) do
  def valid?
    params["user"]["email"] || params["user"]["password"]
  end
 
  def authenticate!
    u = User.authenticate(params["user"]["email"], params["user"]["password"])
    u.nil? ? fail!("Could not log in") : success!(u)
  end
end

module WardenHelpers
  def warden
    env['warden']
  end

  def current_user
    warden.user
  end

  def logged_in?
    !current_user.nil?
  end

  def authenticate!
    warden.authenticate!
  end
  
  def log_out!
    warden.logout
  end
end
