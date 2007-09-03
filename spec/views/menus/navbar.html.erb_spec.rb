require File.dirname(__FILE__) + '/../../spec_helper'

describe "/menus/navbar" do
  before do
    render 'menus/navbar'
  end
  
  #Delete this example and add some real ones or delete this file
  it "should tell you where to find the file" do
    response.should have_tag('p', /Find me in app\/views\/menus\/navbar/)
  end
end
