class Link < ActiveRecord::Base
  belongs_to :to_page, :class_name => "Page"
  belongs_to :from_page, :class_name => "Page"
  
  validates_presence_of :to_page_id, :from_page_id
end
