class UsersController < ApplicationController

  before_action :require_login, only: [:show]

  # display list of users
  def index
    @users = User.all
    render :index
  end

  # display one specific user, by id
  def show
    @user = User.find(params[:id])
    render :show
  end

  # display the user signup form
  def new
    @user = User.new
    render :new
  end

  # process signup form data & create new user
  # login user
  def create
    @user = User.create(user_params)
    login(@user)
    redirect_to @user
  end

  private

  # whitelist permitted form data
  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :password)
  end

end
