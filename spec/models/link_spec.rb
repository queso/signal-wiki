require File.dirname(__FILE__) + '/../spec_helper'

describe Link do
  before(:each) do
    @link = Link.new :from_page_id => 1, :to_page_id => 2
  end

  it "should be valid" do
    @link.save!
    @link.should be_valid
  end
end
