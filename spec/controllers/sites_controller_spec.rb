require File.dirname(__FILE__) + '/../spec_helper'

describe SitesController, "#route_for" do

  it "should map { :controller => 'sites', :action => 'index' } to /sites" do
    route_for(:controller => "sites", :action => "index").should == "/sites"
  end
  
  it "should map { :controller => 'sites', :action => 'new' } to /sites/new" do
    route_for(:controller => "sites", :action => "new").should == "/sites/new"
  end
  
  it "should map { :controller => 'sites', :action => 'show', :id => 1 } to /sites/1" do
    route_for(:controller => "sites", :action => "show", :id => 1).should == "/sites/1"
  end
  
  it "should map { :controller => 'sites', :action => 'edit', :id => 1 } to /sites/1/edit" do
    route_for(:controller => "sites", :action => "edit", :id => 1).should == "/sites/1/edit"
  end
  
  it "should map { :controller => 'sites', :action => 'update', :id => 1} to /sites/1" do
    route_for(:controller => "sites", :action => "update", :id => 1).should == "/sites/1"
  end
  
  it "should map { :controller => 'sites', :action => 'destroy', :id => 1} to /sites/1" do
    route_for(:controller => "sites", :action => "destroy", :id => 1).should == "/sites/1"
  end
  
end

describe SitesController, "handling GET /sites" do

  before do
    @site = mock_model(Site)
    Site.stub!(:find).and_return([@site])
  end
  
  def do_get
    get :index
  end
  
  it "should be successful" do
    do_get
    response.should be_success
  end

  it "should render index template" do
    do_get
    response.should render_template('index')
  end
  
  it "should find all sites" do
    Site.should_receive(:find).with(:all).and_return([@site])
    do_get
  end
  
  it "should assign the found sites for the view" do
    do_get
    assigns[:sites].should == [@site]
  end
end

describe SitesController, "handling GET /sites.xml" do

  before do
    @site = mock_model(Site, :to_xml => "XML")
    Site.stub!(:find).and_return(@site)
  end
  
  def do_get
    @request.env["HTTP_ACCEPT"] = "application/xml"
    get :index
  end
  
  it "should be successful" do
    do_get
    response.should be_success
  end

  it "should find all sites" do
    Site.should_receive(:find).with(:all).and_return([@site])
    do_get
  end
  
  it "should render the found sites as xml" do
    @site.should_receive(:to_xml).and_return("XML")
    do_get
    response.body.should == "XML"
  end
end

describe SitesController, "handling GET /sites/1" do

  before do
    @site = mock_model(Site)
    Site.stub!(:find).and_return(@site)
  end
  
  def do_get
    get :show, :id => "1"
  end

  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should render show template" do
    do_get
    response.should render_template('show')
  end
  
  it "should find the site requested" do
    Site.should_receive(:find).with("1").and_return(@site)
    do_get
  end
  
  it "should assign the found site for the view" do
    do_get
    assigns[:site].should equal(@site)
  end
end

describe SitesController, "handling GET /sites/1.xml" do

  before do
    @site = mock_model(Site, :to_xml => "XML")
    Site.stub!(:find).and_return(@site)
  end
  
  def do_get
    @request.env["HTTP_ACCEPT"] = "application/xml"
    get :show, :id => "1"
  end

  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should find the site requested" do
    Site.should_receive(:find).with("1").and_return(@site)
    do_get
  end
  
  it "should render the found site as xml" do
    @site.should_receive(:to_xml).and_return("XML")
    do_get
    response.body.should == "XML"
  end
end

describe SitesController, "handling GET /sites/new" do

  before do
    @site = mock_model(Site)
    Site.stub!(:new).and_return(@site)
  end
  
  def do_get
    get :new
  end

  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should render new template" do
    do_get
    response.should render_template('new')
  end
  
  it "should create an new site" do
    Site.should_receive(:new).and_return(@site)
    do_get
  end
  
  it "should not save the new site" do
    @site.should_not_receive(:save)
    do_get
  end
  
  it "should assign the new site for the view" do
    do_get
    assigns[:site].should equal(@site)
  end
end

describe SitesController, "handling GET /sites/1/edit" do

  before do
    @site = mock_model(Site)
    Site.stub!(:find).and_return(@site)
  end
  
  def do_get
    get :edit, :id => "1"
  end

  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should render edit template" do
    do_get
    response.should render_template('edit')
  end
  
  it "should find the site requested" do
    Site.should_receive(:find).and_return(@site)
    do_get
  end
  
  it "should assign the found Site for the view" do
    do_get
    assigns[:site].should equal(@site)
  end
end

describe SitesController, "handling POST /sites" do

  before do
    @site = mock_model(Site, :to_param => "1")
    Site.stub!(:new).and_return(@site)
  end
  
  def post_with_successful_save
    @site.should_receive(:save).and_return(true)
    post :create, :site => {}
  end
  
  def post_with_failed_save
    @site.should_receive(:save).and_return(false)
    post :create, :site => {}
  end
  
  it "should create a new site" do
    Site.should_receive(:new).with({}).and_return(@site)
    post_with_successful_save
  end

  it "should redirect to the new site on successful save" do
    post_with_successful_save
    response.should redirect_to(site_url("1"))
  end

  it "should re-render 'new' on failed save" do
    post_with_failed_save
    response.should render_template('new')
  end
end

describe SitesController, "handling PUT /sites/1" do

  before do
    @site = mock_model(Site, :to_param => "1")
    Site.stub!(:find).and_return(@site)
  end
  
  def put_with_successful_update
    @site.should_receive(:update_attributes).and_return(true)
    put :update, :id => "1"
  end
  
  def put_with_failed_update
    @site.should_receive(:update_attributes).and_return(false)
    put :update, :id => "1"
  end
  
  it "should find the site requested" do
    Site.should_receive(:find).with("1").and_return(@site)
    put_with_successful_update
  end

  it "should update the found site" do
    put_with_successful_update
    assigns(:site).should equal(@site)
  end

  it "should assign the found site for the view" do
    put_with_successful_update
    assigns(:site).should equal(@site)
  end

  it "should redirect to the site on successful update" do
    put_with_successful_update
    response.should redirect_to(site_url("1"))
  end

  it "should re-render 'edit' on failed update" do
    put_with_failed_update
    response.should render_template('edit')
  end
end

describe SitesController, "handling DELETE /sites/1" do

  before do
    @site = mock_model(Site, :destroy => true)
    Site.stub!(:find).and_return(@site)
  end
  
  def do_delete
    delete :destroy, :id => "1"
  end

  it "should find the site requested" do
    Site.should_receive(:find).with("1").and_return(@site)
    do_delete
  end
  
  it "should call destroy on the found site" do
    @site.should_receive(:destroy)
    do_delete
  end
  
  it "should redirect to the sites list" do
    do_delete
    response.should redirect_to(sites_url)
  end
end
