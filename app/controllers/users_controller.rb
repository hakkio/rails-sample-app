class UsersController < ApplicationController
  before_filter :signed_in_user, only:     [:edit, :update, :index, :destroy, :following, :followers]
  before_filter :correct_user,   only:     [:edit, :update]
  before_filter :admin_user,     only:     :destroy
  before_filter :signed_in_redirect, only: [:new,  :create]

  def index
    @users = User.paginate(page: params[:page], per_page: 10)
  end

  def new
  	@user = User.new
  end

  def show
  	@user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page], per_page: 10)
  end

  def create
  	@user = User.new(params[:user])
  	if @user.save
      sign_in @user
  		flash[:success] = "Welcome to the Sample App #{@user.name}!"
  		redirect_to @user
  	else
  		render 'new'
  	end
  end

  def edit
    # Removing the below line because it is now handled through
    # the before_filter :correct_user method
    
    #@user = User.find(params[:id])
  end

  def update
    if @user.update_attributes(params[:user])
      sign_in @user
      flash[:success] = "Successfully updated settings"
      redirect_to @user
    else
      render 'edit'
    end
  end


  def destroy
    user = User.find(params[:id])
    if user == current_user
      flash[:error] = "You can't delete yourself."
    else
      user.destroy
      flash[:success] = "User destroyed."
    end
    redirect_to users_url
  end


  def following
    @title = "Following"
    @user = User.find(params[:id])
    @users = @user.followed_users.paginate(page: params[:page])
    render 'show_follow'
  end

  def followers
    @title = "Followers"
    @user = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render "show_follow"
  end

  private

    def signed_in_redirect 
      if signed_in?
        redirect_to root_url
      end 
    end

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_path) unless current_user?(@user)
    end

    def admin_user
      unless current_user.admin?
        redirect_to root_path
      end
    end
end
