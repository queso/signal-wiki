class SitesController < ApplicationController
  before_filter :login_required
  # GET /sites/1
  # GET /sites/1.xml
  def show
    redirect_to edit_site_url
  end

  # GET /sites/1/edit
  def edit
    @site = Site.find(:first)
  end

  # PUT /sites/1
  # PUT /sites/1.xml
  def update
    @site = Site.find(:first)

    respond_to do |format|
      if @site.update_attributes(params[:site])
        flash[:notice] = 'Site was successfully updated.'
        format.html { redirect_to site_url }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @site.errors, :status => :unprocessable_entity }
      end
    end
  end

  def expire_cache
    pages = Page.find(:all)
    pages.each do |p| 
      expire_page("/#{p.permalink}")
    end
    flash[:notice] = "Deleted all cached files."
    redirect_to site_url
  end

  protected
    def authorized?
      admin?
    end

end
