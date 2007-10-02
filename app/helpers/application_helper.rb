# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def author(user)
    (user && user.login) ? user.login.to_s.capitalize : "Anonymous"
  end
  
end
