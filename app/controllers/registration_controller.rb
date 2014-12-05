class RegistrationController < ApplicationController

  include AuthenticatedSystem

  def new
    @user = User.new
    redirect_back_or_default(admin_admin_path) and return if current_user.present?
  end

  def create
    redirect_back_or_default(admin_admin_path) and return if current_user.present?
    logout_keeping_session!
    @user = User.find_by_email( params[:email] )
    if @user.nil?
      @user = User.new( params.slice(:email, :password, :password_confirmation, :name, :organization_id) )
      @user.role = "user"

      if @user.organization_id.nil?
        flash[:alert] = '<p style="color: red;">There were problems with your registration.  Please try again <br /> - Organization is required</p>'
        render :action => 'new' and return
      end

      @user.save
    end



    if @user.valid?
      user = User.authenticate(params[:email], params[:password])
      if user && user.enabled?
        user.update_last_login
        self.current_user = user
        redirect_back_or_default(admin_admin_path)
      else
        note_failed_signin
        @email       = params[:email]
        @remember_me = params[:remember_me]
        flash[:alert] = '<p class="error">There was a problem with your registration.  Please try again</p>'
        render :action => 'new'
      end
    else
      flash[:alert] = '<p style="color: red;">There were problems with your registration.  Please try again</p>'
      render :action => 'new'
    end
  
  end


end
