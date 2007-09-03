require File.dirname(__FILE__) + '/../spec_helper'

describe MenusController do

  #Delete these examples and add some real ones
  it "should use MenusController" do
    controller.should be_an_instance_of(MenusController)
  end


  it "GET 'navbar' should be successful" do
    get 'navbar'
    response.should be_success
  end
end
