# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def site_name
    site ? site.title : "Signal"
  end
  
  def author(user_id)
    user = User.find(user_id)
    user.login ? user.login.capitalize : "Anonymous"
  end
  
end
