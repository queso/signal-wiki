require File.dirname(__FILE__) + '/../spec_helper'

describe ApplicationHelper do
  
  it "returns gravatar_icons for existing email with default size 70" do
    Digest::MD5.stub!(:hexdigest).and_return "digest"
    gravatar_url("test@email.com").should == "http://www.gravatar.com/avatar.php?size=70&gravatar_id=digest"
  end
  
  it "returns gravatar_icons for existing email with requested size" do
    Digest::MD5.stub!(:hexdigest).and_return "digest"
    gravatar_url("test@email.com", 80).should == "http://www.gravatar.com/avatar.php?size=80&gravatar_id=digest"
  end
  
  it "returns gravatar_icons for non-existing email" do
    Digest::MD5.should_receive(:hexdigest).with("nil@nil.com").and_return "digest"
    gravatar_url(nil).should == "http://www.gravatar.com/avatar.php?size=70&gravatar_id=digest"
  end
  
  
end