# == Schema Information
# Schema version: 8
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
#  private    :boolean       
#  version    :integer       
#

class Page < ActiveRecord::Base
  belongs_to :user
  acts_as_versioned
  
  
  before_save :set_permalink
  
  def set_permalink
    self.permalink = "#{title.downcase.strip.gsub(' ', '-')}" if self.permalink.blank?
  end
  
  def to_param
    self.permalink
  end
  
  def self.find_all_by_wiki_word(wiki_word)
    pages = self.find(:all)
    pages.select {|p| p.body =~ /#{wiki_word}/i}
  end
  
end
