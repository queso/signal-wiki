# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def author(user_id)
    user = user_id ? User.find(user_id) : User.new
    user.login ? user.login.capitalize : "Anonymous"
  end
  
end
