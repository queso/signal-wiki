# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  

  # render new.rhtml
  def new
  end

  def create
    if using_open_id?
      cookies[:use_open_id] = {:value => '1', :expires => 1.year.from_now.utc}
      open_id_authentication
    else
      cookies[:use_open_id] = {:value => '0', :expires => 1.year.ago.utc}
      self.current_user = User.authenticate(params[:login], params[:password])
      if logged_in?
        if params[:remember_me] == "1"
          self.current_user.remember_me
          cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
        end
        cookies[:logged_in] = current_user.login
        redirect_back_or_default('/')
        flash[:notice] = "Logged in successfully"
      else
        render :action => 'new'
      end
    end
  end

  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default('/')
  end
  
  protected
  
  def open_id_authentication
    # Pass optional :required and :optional keys to specify what sreg fields you want.
    # Be sure to yield registration, a third argument in the #authenticate_with_open_id block.
    authenticate_with_open_id(params[:openid_url], :required => [ :nickname, :email ]) do |result, identity_url, registration|
      if result.successful?
        if !@user = User.find_by_identity_url(identity_url)
          @user = User.new(:identity_url => identity_url)
          assign_registration_attributes!(registration)
        end
        self.current_user = @user
        successful_login
      else
        failed_login(result.message || "Sorry could not log in with identity URL: #{identity_url}")
      end
    end
  end
  
  def assign_registration_attributes!(registration)
    { :login => 'nickname', :email => 'email' }.each do |model_attribute, registration_attribute|
      unless registration[registration_attribute].blank?
        @user.send("#{model_attribute}=", registration[registration_attribute])
      end
    end
    @user.save!
  end
  
  private
  
    def successful_login
      redirect_to pages_url
      flash[:notice] = "Logged in successfully"
    end

    def failed_login(message)
      flash.now[:error] = message
      render :action => 'new'
    end
end
