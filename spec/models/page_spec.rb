require File.dirname(__FILE__) + '/../spec_helper'

describe Page, "validity" do
  fixtures :sites
  
  before(:each) do
    @page = Page.new :site_id => 1
    @site = mock_model(Site)
  end

  it "should not be valid" do
    @page.should_not be_valid
  end
  
  it "is valid with title and body" do
    @page.title = "Monkeys"
    @page.body  = "Hello, banana!"
    @page.should be_valid
  end
  
  it "should not be valid if site is spam" do
    @page.stub!(:is_spam?).and_return true
    @page.stub!(:site).and_return @site
    @site.should_receive(:akismet_key?).and_return true
    @page.should_not be_valid
  end
  
  it "should connect to viking for spam info" do
    @v = mock_model(Object)
    Viking.should_receive(:connect).and_return @v
    @v.should_receive(:check_comment).and_return :spam => true
    @page.is_spam?(@page.site).should == true
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
    @page1 = Page.create! :title => "outbound", :permalink => "outbound", :body => "empty", :site_id => sites(:first).id
  end
  
  it "edits a locked page" do
    @page1.lock
    @page1.body = "Blah blah"
    @page1.save
    @page1.should_not be_valid
  end
  
  it "sets locked correctly" do
    @page1.lock
    @page1.should be_locked
    @page1.unlock
    @page1.should_not be_locked
  end
  
  it "edits a previous locked but now unlocked page" do
    @page1.lock
    @page1.unlock
    @page1.body = "Blah blah"
    @page1.save
    @page1.should be_valid
  end
  
end
