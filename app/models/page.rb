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
  attr_accessor :ip, :agent, :referrer
  
  before_save :set_permalink
  
  def validate
    site = Site.find(:first)
    if site.akismet_key? && is_spam?(site)
      errors.add_to_base "Your comment was marked as spam, please contact the site admin if you feel this was a mistake."
    end
  end
  
  def is_spam?(site)
    v = Viking.connect("akismet", {:api_key => site.akismet_key, :blog => site.akismet_url})
    response = v.check_comment(:comment_content => body.to_s, :comment_author => user.login.to_s, :user_ip => ip.to_s, :user_agent => agent.to_s, :referrer => referrer.to_s)
    logger.info "Calling Akismet for page #{permalink} by #{user.login.to_s} using ip #{ip}:  #{response[:spam]}"
    return response[:spam]
  end
  
  def request=(request)
    self.ip       = request.env["REMOTE_ADDR"]
    self.agent    = request.env["HTTP_USER_AGENT"]
    self.referrer = request.env["HTTP_REFERER"]
  end
  
  def set_permalink
    if self.permalink.blank?
      self.permalink = Page.count == 0 ? "home" : "#{title.downcase.strip.gsub(' ', '-')}" 
    end
  end
  
  def to_param
    self.permalink
  end
  
  def self.find_all_by_wiki_word(wiki_word)
    pages = self.find(:all)
    pages.select {|p| p.body =~ /#{wiki_word}/i}
  end
  
end
