require File.dirname(__FILE__) + "/../spec_helper"

describe FlagsController, "a user not logged in" do
  fixtures :sites, :users, :pages
  integrate_views
  
  before do
    controller.stub!(:logged_in?).and_return false
    controller.stub!(:current_user).and_return :false
  end
  
  %w[index new].each do |action|
     it "#{action} should redirect to login" do
       get action
       response.should redirect_to('session/new')
     end
   end

  it 'can not flag something' do
    post :create, :flag => { :flaggable_type => 'Page', :flaggable_id => 1, :reason => 'outdated' }
    response.should redirect_to('session/new')
  end
  
  it 'can not delete' do
    delete :destroy, :id => "1"
    response.should_not be_success
    response.should redirect_to('session/new')
  end
end

describe FlagsController, "a user logged in as normal user" do
  fixtures :sites, :pages, :page_versions, :users
  integrate_views
  
  before do
    # Mocking this was a bitch.
    @user = users(:jeremy)
    
    controller.stub!(:require_login)
    controller.stub!(:logged_in?).and_return true
    controller.stub!(:current_user).and_return @user
  end
  
  it "does not render 'index'" do
    get :index
    response.should redirect_to('session/new')
  end
  
  it 'canflag something' do
    lambda {
      post :create, :flag => { :flaggable_type => 'Page', :flaggable_id => 1, :reason => 'outdated', :user_id => @user.id }
      response.should redirect_to('pages/hai')
    }.should change(Flag, :count).by(1)
  end
  it 'can not flag same page twice' do
    post :create, :flag => { :flaggable_type => 'Page', :flaggable_id => 1, :reason => 'outdated', :user_id => @user.id }
    lambda {
      post :create, :flag => { :flaggable_type => 'Page', :flaggable_id => 1, :reason => 'outdated', :user_id => @user.id }
      #flash[:notice].should == "You already flagged this content!"
    }.should_not change(Flag, :count)
  end
  
  it "render 'new'" do
    get :new, :flaggable_type => 'Page', :flaggable_id => 1
    response.should be_success
    response.should render_template('new')
  end
  
  it "render / with error if flaggable_type is not found" do
    get :new, :flaggable_type => 'NotFound', :flaggable_id => 1
    response.should_not be_success
    response.should redirect_to('/')
    #flash[:error].should_not be_empty
  end

  it "can delete a page" do
    flag = @user.flags.create({ :flaggable_type => 'Page', :flaggable_id => 1, :reason => 'outdated', :user_id => @user.id })
    lambda do
      delete :destroy, :id => flag
      response.should redirect_to('flags')
    end.should change(Flag, :count)
  end
end


describe FlagsController, "a user logged in as admin" do
  fixtures :sites, :pages, :page_versions, :users
  integrate_views
  
  before do
    @user = users(:admin)
    controller.stub!(:require_login)
    controller.stub!(:logged_in?).and_return true
    controller.stub!(:current_user).and_return @user
  end
  
  it "renders 'index'" do
    get :index
    response.should be_success
    response.should render_template("index")    
  end
  
  it 'can flag something' do
    lambda {
      post :create, :flag => { :flaggable_type => 'Page', :flaggable_id => 1, :reason => 'outdated', :user_id => @user.id }
      response.should redirect_to('pages/hai')
    }.should change(Flag, :count).by(1)
  end
  
  it "render 'new'" do
    get :new, :flaggable_type => 'Page', :flaggable_id => 1
    response.should be_success
    response.should render_template("new")
  end
  it 'can not flag same page twice' do
    post :create, :flag => { :flaggable_type => 'Page', :flaggable_id => 1, :reason => 'outdated', :user_id => @user.id }
    lambda {
      post :create, :flag => { :flaggable_type => 'Page', :flaggable_id => 1, :reason => 'outdated', :user_id => @user.id }
      #flash[:notice].should == "You already flagged this content!"
    }.should_not change(Flag, :count)
  end
  it "render / with error if flaggable_type is not found" do
    get :new, :flaggable_type => 'NotFound', :flaggable_id => 1
    response.should_not be_success
    response.should redirect_to('/')
    #flash[:error].should_not be_empty
  end
  it "can delete a page" do
    flag = @user.flags.create({ :flaggable_type => 'Page', :flaggable_id => 1, :reason => 'outdated', :user_id => @user.id })
    lambda do
      delete :destroy, :id => flag
      response.should redirect_to('flags')
    end.should change(Flag, :count)
  end
  
end

