# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def author(user_id)
    user = User.find(user_id) if user_id
    (user && user.login) ? user.login.to_s.capitalize : "Anonymous"
  end
  
end
