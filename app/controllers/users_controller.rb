class UsersController < ApplicationController
  

  def index
  end

  def show
    @shop = Shop.all
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

  private

  def user_params
    params.require(:user).permit(:name, :email, :profile_image)
  end
end
