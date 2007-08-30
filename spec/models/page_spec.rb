require File.dirname(__FILE__) + '/../spec_helper'

describe Page do
  before(:each) do
    @page = Page.new
  end

  it "should be valid" do
    @page.should be_valid
  end
  
  it "should have a permalink" do
    @page.title = "Home Page"
    @page.save
    @page.should have_permalink
  end
  
end
