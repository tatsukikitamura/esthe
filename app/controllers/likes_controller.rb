class LikesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_shop

  def create
    current_user.likes.find_or_create_by!(shop: @shop)
    redirect_back fallback_location: shop_path(@shop), notice: 'いいねしました。'
  end

  def destroy
    like = current_user.likes.find_by(shop: @shop)
    like&.destroy
    redirect_back fallback_location: shop_path(@shop), notice: 'いいねを解除しました。'
  end

  private

  def set_shop
    @shop = Shop.find(params[:shop_id])
  end
end



