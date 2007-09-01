require File.dirname(__FILE__) + '/../../spec_helper'

describe "/sites/show.html.erb" do
  include SitesHelper
  
  before do
    @site = mock_model(Site)
    @site.stub!(:title).and_return("MyString")
    @site.stub!(:akismet_key).and_return("MyString")
    @site.stub!(:akismet_url).and_return("MyString")
    @site.stub!(:require_approval).and_return(false)
    @site.stub!(:require_login_to_post).and_return(false)
    @site.stub!(:disable_teh).and_return(false)

    assigns[:site] = @site
  end

  it "should render attributes in <p>" do
    render "/sites/show.html.erb"
    response.should have_text(/MyString/)
    response.should have_text(/MyString/)
    response.should have_text(/MyString/)
    response.should have_text(/als/)
    response.should have_text(/als/)
    response.should have_text(/als/)
  end
end

