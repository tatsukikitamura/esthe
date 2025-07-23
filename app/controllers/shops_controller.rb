class ShopsController < ApplicationController
  def index
    @shops = Shop.includes(:persons, :shop_comments).all
  end

  def show
    @shop = Shop.includes(:persons, shop_comments: :user).find(params[:id])
    @shop_comment = ShopComment.new 
  end
end
