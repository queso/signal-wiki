# == Schema Information
# Schema version: 13
#
# Table name: links
#
#  id           :integer       not null, primary key
#  from_page_id :integer       
#  to_page_id   :integer       
#  created_at   :datetime      
#  updated_at   :datetime      
#

class Link < ActiveRecord::Base
  belongs_to :to_page, :class_name => "Page"
  belongs_to :from_page, :class_name => "Page"
  
  validates_presence_of :to_page_id, :from_page_id
end
