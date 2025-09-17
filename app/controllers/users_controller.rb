class UsersController < ApplicationController
  before_action :authenticate_user!, only: [:show, :edit, :update, :destroy, :likes]

  def index
  end

  def show
    @liked_shops = current_user.liked_shops.includes(:persons)
    @external_likes = current_user.external_likes
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(user_params)
      redirect_to users_path, notice: 'プロフィールが更新されました。'
    else
      render :edit
    end
  end

  def destroy
    user = current_user
    user.destroy
    redirect_to root_path
  end

  def likes
    @liked_shops = current_user.liked_shops.includes(:persons)
    @external_likes = current_user.external_likes
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :profile_image)
  end
end
