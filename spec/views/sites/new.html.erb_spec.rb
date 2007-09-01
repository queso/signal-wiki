require File.dirname(__FILE__) + '/../../spec_helper'

describe "/sites/new.html.erb" do
  include SitesHelper
  
  before do
    @site = mock_model(Site)
    @site.stub!(:new_record?).and_return(true)
    @site.stub!(:title).and_return("MyString")
    @site.stub!(:akismet_key).and_return("MyString")
    @site.stub!(:akismet_url).and_return("MyString")
    @site.stub!(:require_approval).and_return(false)
    @site.stub!(:require_login_to_post).and_return(false)
    @site.stub!(:disable_teh).and_return(false)
    assigns[:site] = @site
  end

  it "should render new form" do
    render "/sites/new.html.erb"
    
    response.should have_tag("form[action=?][method=post]", sites_path) do
      with_tag("input#site_title[name=?]", "site[title]")
      with_tag("input#site_akismet_key[name=?]", "site[akismet_key]")
      with_tag("input#site_akismet_url[name=?]", "site[akismet_url]")
      with_tag("input#site_require_approval[name=?]", "site[require_approval]")
      with_tag("input#site_require_login_to_post[name=?]", "site[require_login_to_post]")
      with_tag("input#site_disable_teh[name=?]", "site[disable_teh]")
    end
  end
end


