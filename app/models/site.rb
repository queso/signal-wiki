# == Schema Information
# Schema version: 10
#
# Table name: sites
#
#  id                    :integer       not null, primary key
#  title                 :string(255)   
#  akismet_key           :string(255)   
#  akismet_url           :string(255)   
#  require_approval      :boolean       
#  require_login_to_post :boolean       
#  disable_teh           :boolean       
#  created_at            :datetime      
#  updated_at            :datetime      
#

class Site < ActiveRecord::Base
  has_many :pages

  def title
    super || "Signal"
  end
  
end
