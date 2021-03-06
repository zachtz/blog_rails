class UsersController < ApplicationController 

  # these callback methods will be executed before the actions specified within the 
  # actions array (if only is used or when except is used, those actions not specified)
  before_filter :find_user, :only => [
                                      :edit, :show, :update, 
                                      :pending_friendships, 
                                      :ensure_correct_user, 
                                      :set_as_admin,
                                    ]

  before_filter :authorize_user, :except => [:new, :show, :create]
  before_filter :current_user, :only => [:index]
  before_filter :ensure_correct_user, :only => [:edit, :destroy, :update]
  before_filter :admin_only, :only => [:index, :set_as_admin]
  before_filter :skip_password_attribute, :only => [:update]

  def index
    @users = User.all 
  end

  def new
  	@user = User.new
  end

  def edit
  end

  def show
  end

  def create
  	@user = User.new(params[:user])
  	if @user.save
  		#redirect
  		redirect_to root_url, :notice => 'Successfully Signed Up'
  		#show message
  	else
  		#stay on the same page
  		render 'new'
  		#show the errors
  		flash[:alert] = "Could not sign you up"
  	end
  end

  def update
  	# if params[:user][:password].blank?
    # params[:user].delete :password
    # params[:user].delete :password_confirmation
    # end 
    # params[:user].delete(:password) if params[:user][:password].blank?
  	if @user.update_attributes(params[:user])
  		redirect_to root_url, :notice => 'Successfully Updated Profile'
  	else
  		render 'edit'
  		flash[:alert] = "There was an error updating your profile"
  	end
  end

  def set_as_admin
    admin_user = User.set_user_as_admin(@user)
    respond_to do |format|
      if admin_user
      format.html {redirect_to manage_users_path, :notice => "Successfully set #{@user.email} as admin"}
      format.js { }
    else
      redirect_to manage_users_path, :alert => "Could not complete the tast"
    end
    end
  end

  def user_posts
    @user = User.find(params[:id])
    @posts = @user.my_posts
  end

  def find_user
    @user = User.find(params[:id])
  end

  def skip_password_attribute
    if params[:password].blank? && params[:password_confirmation].blank?
      params.except!(:password, :password_confirmation)
    end
  end

  def admin_only
    redirect_to root_url, :alert => 'Only Admin can access this resource' unless is_admin?
  end

  def ensure_correct_user
    redirect_to root_url, :notice => "You are not authorized to do that" unless is_admin? || can_manage_user(@user)
  end
end
