class Admin::UsersController < Admin::AdminController
  before_filter :get_user,          :only => [:edit, :update, :destroy]
  before_filter :get_organizations, :only => [:index, :new, :edit]
  before_filter :get_sites,         :only => [:new, :edit]

  def index
    @new_user = User.new
    @users    = User.order('id asc').all
  end

  def new
    @user = User.new(params[:user])
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      redirect_to :admin_users
    else
      get_organizations
      get_sites
      render :new
    end
  end

  def edit
  end

  def update
    if @user.update_attributes(params[:user])
      redirect_to :admin_users
    else
      get_organizations
      get_sites
      render :edit
    end
  end

  def destroy
    @user.destroy

    redirect_to :admin_users
  end

  private

  def get_user
    @user = User.find(params[:id])
  end

  def get_organizations
    @organizations = Organization.select([:id, :name]).all
  end

  def get_sites
    @sites = Site.select([:id, :name]).all
  end
end

