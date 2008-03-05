class PagesController < ApplicationController
  before_filter :require_login, :except => [:index, :show, :revision]
  before_filter :check_private, :only => [:show, :revision]
  caches_page :show
  cache_sweeper :page_sweeper, :only => [:create, :update]
  
  
  # GET /pages
  # GET /pages.xml
  def index
    redirect_to wiki_page_url("home")

    #respond_to do |format|
    #  format.html # index.html.erb
    #  format.xml  { render :xml => @pages }
    #end
  end

  # GET /pages/1
  # GET /pages/1.xml
  def show
    @page = Page.find_by_permalink(params[:id] || "home")
    
    
    if @page
      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @page }
      end
    else
      session[:new_title] = params[:id]
      redirect_to new_page_url()
    end
  end

  def revision
    @page = Page.find_by_permalink(params[:id])
    @page = Page.find_version(@page.id, params[:version])
    
    respond_to do |format|
      format.html
    end
  end

  # GET /pages/new
  # GET /pages/new.xml
  def new
    @page = Page.new(:title => session[:new_title].to_s.gsub("-", " ").capitalize, :permalink => session[:new_title])
    @attachments = Attachment.find_parent(:all)
    @button_text = "Add this page"
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @page }
    end
  end

  # GET /pages/1/edit
  def edit
    @page = Page.find_by_permalink(params[:id])
    @attachments = Attachment.find_parent(:all)
    @button_text = "Save this version"
  end

  # POST /pages
  # POST /pages.xml
  def create
    @page = Page.new(params[:page])
    @page.request = request
    @page.user = logged_in? ? current_user : User.new

    respond_to do |format|
      if @page.save
        #flash[:notice] = 'Page was successfully created.'
        format.html { redirect_to(wiki_page_url(@page)) }
        format.xml  { render :xml => @page, :status => :created, :location => @page }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @page.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /pages/1
  # PUT /pages/1.xml
  def update
    @page = Page.find_by_permalink(params[:id])
    @page.request = request
    @page.user = logged_in? ? current_user : User.new
    
    respond_to do |format|
      if @page.update_attributes(params[:page])
        #flash[:notice] = 'Page was successfully updated.'
        format.html { redirect_to(wiki_page_url(@page)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @page.errors, :status => :unprocessable_entity }
      end
    end
  end

  def rollback
    @page = Page.find_by_permalink(params[:id])
    @page.revert_to!(params[:version])
    expire_page("/#{@page.permalink}")
    respond_to do |format|
      #flash[:notice] = "#{@page.title} was successfully rolled back to revision #{params[:version]}"
      format.html { redirect_to(wiki_page_url(@page)) }
      format.xml  { head :ok }
    end
  end

  def search
    @pages = Page.find_with_index("#{params[:query]}")
    respond_to do |format|
      format.html
      format.xml
      format.js
    end
  end

  # DELETE /pages/1
  # DELETE /pages/1.xml
  def destroy
    @page = Page.find(params[:id]).destroy
    respond_to do |format|
      format.html { redirect_to(pages_url) }
      format.xml  { head :ok }
    end
  end
  
  
  def check_private
    @page = Page.find_by_permalink(params[:id])
    return unless @page
    if @page.private_page
      login_required
    else 
      true
    end
  end
  
  def caching_allowed
    if @page
      ! @page.private_page
    end
  end
  
  def require_login
    site.require_login_to_post ? login_required : true
  end
  
end
