require File.dirname(__FILE__) + '/../spec_helper'

describe Page, "validity" do
  fixtures :sites
  
  before(:each) do
    @page = Page.new :site_id => 1
  end

  it "should not be valid" do
    @page.should_not be_valid
  end
  
  it "is valid with title and body" do
    @page.title = "Monkeys"
    @page.body  = "Hello, banana!"
    @page.should be_valid
  end
  
end

describe Page, "creating links" do
  fixtures :sites

  before do
    @page1 = Page.create! :title => "outbound", :permalink => "outbound", :body => "empty", :site_id => 1
    @page2 = Page.new :title => "hi!", :body => "This is my page [[outbound]]", :site_id => 1
  end
  
  it "creates a link" do
    c = Link.count
    @page2.save!
    Link.count.should == c+1
    #lambda{ @page2.save! }.should change { Link.count }.by(1)
  end
end  
