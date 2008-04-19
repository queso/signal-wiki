require File.dirname(__FILE__) + '/../spec_helper'

describe PageSweeper do
  fixtures :sites, :pages
  before(:each) do
    @page = Page.new :title => "hee haw", :body => "moop", :permalink => "hee-haw", :site_id => 1 
    @page1 = mock_model(Page)
    @page2 = mock_model(Page)
    @pages = [@page1, @page2]
    @permalink = "hee-haw"
    @page_sweeper = PageSweeper.send(:new)
  end

  it "should expire all pages with same permalink" do
    Page.should_receive(:find_all_by_wiki_word).at_least(1).with("hee haw").and_return @pages
    @pages.each do |page|
      page.should_receive(:permalink).at_least(1)
    end
    @page_sweeper.should_receive(:expire_page).exactly(3)
    @page.save
  end
end
