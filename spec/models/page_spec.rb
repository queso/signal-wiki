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
  
  it "creates a new empty wiki link" do
    @page1.body = "New wiki test [[link]]"
    @page1.save!
    @page1.should be_valid
  end
  
end  

describe Page, "locking pages" do
  fixtures :sites
  
  before do
    @page1 = Page.create! :title => "outbound", :permalink => "outbound", :body => "empty", :site_id => 1
  end
  
  it "edit a locked page" do
    @page1.lock
    @page1.body = "Blah blah"
    @page1.save
    @page1.should_not be_valid
  end
  
  it "edit an unlocked page" do
    @page1.lock
    @page1.unlock
    @page1.body = "Blah blah"
    @page1.save
    @page1.should be_valid
  end
  
end
