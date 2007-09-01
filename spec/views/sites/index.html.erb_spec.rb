require File.dirname(__FILE__) + '/../../spec_helper'

describe "/sites/index.html.erb" do
  include SitesHelper
  
  before do
    site_98 = mock_model(Site)
    site_98.should_receive(:title).and_return("MyString")
    site_98.should_receive(:akismet_key).and_return("MyString")
    site_98.should_receive(:akismet_url).and_return("MyString")
    site_98.should_receive(:require_approval).and_return(false)
    site_98.should_receive(:require_login_to_post).and_return(false)
    site_98.should_receive(:disable_teh).and_return(false)
    site_99 = mock_model(Site)
    site_99.should_receive(:title).and_return("MyString")
    site_99.should_receive(:akismet_key).and_return("MyString")
    site_99.should_receive(:akismet_url).and_return("MyString")
    site_99.should_receive(:require_approval).and_return(false)
    site_99.should_receive(:require_login_to_post).and_return(false)
    site_99.should_receive(:disable_teh).and_return(false)

    assigns[:sites] = [site_98, site_99]
  end

  it "should render list of sites" do
    render "/sites/index.html.erb"
    response.should have_tag("tr>td", "MyString", 2)
    response.should have_tag("tr>td", "MyString", 2)
    response.should have_tag("tr>td", "MyString", 2)
    response.should have_tag("tr>td", false, 2)
    response.should have_tag("tr>td", false, 2)
    response.should have_tag("tr>td", false, 2)
  end
end

