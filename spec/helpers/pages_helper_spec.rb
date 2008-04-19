require File.dirname(__FILE__) + '/../spec_helper'

describe PagesHelper do
  
  it "has the right amount of greediness on parsing wiki links" do
    self.stub!(:wiki_link).and_return "MONKEYS"
    wikified_body("hello[[there]]whats[[up]]").should == "<p>helloMONKEYSwhatsMONKEYS</p>"
    wikified_body("hello[[there|hai]]whats[[up|doc]]").should == "<p>helloMONKEYSwhatsMONKEYS</p>"
  end
  
  it "parses wiki links" do
    self.should_receive(:wiki_link).with("up",    nil).and_return("MONKEYS")
    self.should_receive(:wiki_link).with("there", "hai").and_return("MONKEYS")
    wikified_body("hello[[there|hai]]whats[[up]]").should == "<p>helloMONKEYSwhatsMONKEYS</p>"
  end
  
end

describe PagesHelper do
  before do
    @wiki_word = "o hai"
    @link_text = "test"
    @perma_link = {:permalink => "o-hai"}
    @class_str = "class=\"new_wiki_link\""
  end
    it "links to wiki permalink if page exists" do
      
    Page.should_receive(:exists?).with(@perma_link).and_return true
    link = wiki_link(@wiki_word, @link_text)
    link.should include(@link_text)
    link.should_not include(@wiki_word)
    link.should_not include(@class_str)
    
    end
    it "links to wiki permalink with proper style if page doesnot exist" do
      
    Page.should_receive(:exists?).with(@perma_link).and_return false
    link = wiki_link(@wiki_word, @link_text)
    link.should include(@link_text)
    link.should_not include(@wiki_word)
    link.should include(@class_str)
    end
  end
  
describe PagesHelper do
  before do
    @site = mock_model(Site)
    @form = mock_model(Object)
    @attr = :body
      self.should_receive(:site).and_return @site
  end
    it "should render textarea if site disable teh" do
      @site.should_receive(:disable_teh).and_return true
      @form.should_receive(:text_area)
      text_input(@form, @attr)
    end
    it "should render tech if site enable teh" do
      @site.should_receive(:disable_teh).and_return false
      @form.should_not_receive(:text_area)
      self.should_receive(:textile_editor)
      text_input(@form, @attr)
    end
 end
describe PagesHelper do
  before do
    @id = 1
    @page = mock_model(Page)
    @version = mock_model(Page)
    @version2 = mock_model(Page)
  end
    it "checks existing page with same version" do
      Page.should_receive(:find).with(@id).and_return @page
      @page.should_receive(:version).and_return @version
      current_revision(@id, @version).should == true
    end
    it "checks existing page with different version" do
      Page.should_receive(:find).with(@id).and_return @page
      @page.should_receive(:version).and_return @version2
      current_revision(@id, @version).should == false
    end
    it "checks non-existing page version" do
      Page.should_receive(:find).with(@id).and_return nil
      current_revision(@id, @version).should == false
    end
 end