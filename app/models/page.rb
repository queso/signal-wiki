# == Schema Information
# Schema version: 3
#
# Table name: pages
#
#  id         :integer       not null, primary key
#  title      :string(255)   
#  body       :text          
#  user_id    :integer       
#  permalink  :string(255)   
#  created_at :datetime      
#  updated_at :datetime      
#  version    :integer       
#

class Page < ActiveRecord::Base
  belongs_to :user
  acts_as_versioned
  acts_as_textiled :body
  
end
