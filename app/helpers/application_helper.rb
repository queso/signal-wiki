# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def author(user_id)
    user = User.find(user_id) if user_id
    (user && user.login) ? user.login.to_s.capitalize : "Anonymous"
  end
  
  def gravatar_url(email, size=70)
    email ||= "nil@nil.com" 
    require 'digest/md5'
    digest = Digest::MD5.hexdigest(email)
    "http://www.gravatar.com/avatar.php?size=#{size}&gravatar_id=#{digest}"
  end
  
end
