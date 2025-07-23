class UsersController < ApplicationController
  def index
  end

  def show
    @shop = Shop.all
  end

  def edit
  end
  def destroy
    user = current_user
    user.destroy
    redirect_to root_path
  end
end
