require File.dirname(__FILE__) + '/../spec_helper'

describe Site do
  before(:each) do
    @site = Site.new
  end

  it "should be valid" do
    @site.should be_valid
  end
end
