class UsersController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead

  def index
    @users = User.find(:all)
  end

  def show
    @user = User.find(params[:id])
  end

  # render new.rhtml
  def new
  end

  def create
    @user = User.new(params[:user])
    @user.save!
    self.current_user = @user
    redirect_back_or_default('/')
    flash[:notice] = "Thanks for signing up!"
  rescue ActiveRecord::RecordInvalid
    render :action => 'new'
  end

end
