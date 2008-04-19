require File.dirname(__FILE__) + '/../spec_helper'

def valid_user_attributes
  {:login => "test",
   :email => "user@test.com",
   :password => "password",
   :password_confirmation => "password"}
end
describe User, "validity" do
  before(:each) do
    @user = User.new
  end

  it "should not be valid" do
    @user.should_not be_valid
  end
  
  it "is valid if open_id" do
    @user.identity_url = "open_id"
    @user.should be_valid
    puts @user.errors.inspect
  end

  it "is valid with login, email, password, and passwrod_confirmation if not open_id" do
    @user.update_attributes(valid_user_attributes)
    @user.should be_valid
    puts @user.errors.inspect
  end  
end

describe User, "autheticate" do
  before(:each) do
    @user = User.new(valid_user_attributes)
    @user.save
    @user.reload
  end

  it "should have encrypted password" do
    @user.crypted_password.should_not be_blank
    @user.crypted_password.should_not == @user.password
  end
  
  it "should autheticate the right password" do
    User.authenticate(@user.login, @user.password).should == @user
  end

  it "should autheticate the wrong password" do
    User.authenticate(@user.login, "#{@user.password}11").should == nil
  end  
end

describe User, "remember cookies" do
  before(:each) do
    @user = User.new(valid_user_attributes)
    @user.save
    @user.reload
  end

  it "should set remember_token" do
    @user.remember_token_expires_at.should be_blank
    @user.remember_token.should be_blank
    @user.remember_me
    @user.remember_token_expires_at.should_not be_blank
    @user.remember_token.should_not be_blank

    @user.forget_me
    @user.remember_token_expires_at.should be_blank
    @user.remember_token.should be_blank
  end  
  
  it "should expires" do
    @user.remember_me_for(1.second)
    sleep(2)
    @user.remember_token?.should == false
  end
end