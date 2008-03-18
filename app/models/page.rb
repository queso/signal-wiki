# == Schema Information
# Schema version: 13
#
# Table name: pages
#
#  id           :integer       not null, primary key
#  title        :string(255)   
#  body         :text          
#  user_id      :integer       
#  permalink    :string(255)   
#  created_at   :datetime      
#  updated_at   :datetime      
#  private_page :boolean       
#  version      :integer       
#  site_id      :integer       
#  locked       :boolean       
#

class Page < ActiveRecord::Base
  belongs_to :user
  belongs_to :site
  has_many :inbound_links,  :class_name => "Link", :foreign_key => "to_page_id"
  has_many :outbound_links, :class_name => "Link", :foreign_key => "from_page_id"
  acts_as_versioned
  self.non_versioned_columns << 'locked_at'
  attr_accessor :ip, :agent, :referrer
  acts_as_indexed :fields => [:title, :body, :author]

  can_be_flagged :reasons => [:spam, :outdated, :inaccurate]
  
  before_save :set_permalink
  before_update :set_links
  after_create  :set_links
  validates_presence_of :title, :body
  validate_on_update :updatable

  def validate
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
      self.permalink = Page.count == 0 ? "home" : "#{title.downcase.strip.gsub(/ |\.|@/, '-')}" 
    end
  end
  
  def set_links
    Link.transaction do
      # outbound_links.delete_all
      body.scan(/\[\[(.*?)\]\]/).each do |link|
        link = link[0].downcase.gsub(' ', '-')
        if page = site.pages.find_by_permalink(link)
          Link.create! :from_page_id => id, :to_page_id => page.id
        else
          logger.warn "We couldn't find links for #{link}"
        end
      end
    end
  end
  
  def to_param
    self.permalink
  end
  
  def author
    (user && user.login) ? user.login.to_s.capitalize : "Anonymous"
  end
  
  def lock
    self.without_revision do
      self.update_attribute(:locked_at, Time.now)
    end
    RAILS_DEFAULT_LOGGER.info "LOCKED #{self.permalink}"
  end
  
  def locked?
    locked_at.nil? or locked_at > Time.now
  end
  
  def unlock
    self.without_revision do
      self.update_attribute(:locked_at, nil)
    end
    RAILS_DEFAULT_LOGGER.info "UNLOCKED #{self.permalink}"
  end
  
  def self.find_all_by_wiki_word(wiki_word, site = nil)
    site ||= Site.find(:first)
    pages = site.pages.find(:all)
    pages.select {|p| p.body =~ /#{wiki_word}/i}
  end
  
  private
  
  def updatable
    unless self.locked_at.nil?
      errors.add("page", "is locked from editing.")
    end
  end
  
end
