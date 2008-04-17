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