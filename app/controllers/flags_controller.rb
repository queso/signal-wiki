# This controller handles the 'flag as inappropriate' functionality
class FlagsController < ApplicationController
  before_filter :login_required
# You probably have your own 'admin' filter
  before_filter :admin_required, :only => :index
protected
  def admin_required
    raise AccessDenied unless current_user.admin?
  end

public
  
  # collection methods

  def create
    flag = current_user.flags.create params[:flag]
    flash[:notice] = if flag.new_record?
      "You already flagged this content!"
    else # success
      "Content has been flagged!"
    end

    respond_to do |format|# note: you'll need to ensure that this route exists
      format.html { redirect_to flag.flaggable }
      # format.js # render some js trickery
    end
  end

  def index
    @flags = Flag.find(:all, :order => "id desc")
    #We suggest 'will_paginate' plugin
    #@flags = Flag.paginate(:all, :page => params[:page])

    respond_to do |format|
      format.html {} # index.html.erb
      format.xml  { render :xml => @flags }
    end
  end    
   
   
  def destroy
    Flag.find(params[:id]).destroy
    redirect_to flags_url
  end

end