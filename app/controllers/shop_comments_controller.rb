class ShopCommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_shop

  def create
    @shop_comment = @shop.shop_comments.build(shop_comment_params)
    @shop_comment.user = current_user
    
    if @shop_comment.save
      redirect_to @shop, notice: 'コメントが投稿されました。'
    else
      redirect_to @shop, alert: 'コメントの投稿に失敗しました。'
    end
  end

  def destroy
    @shop_comment = current_user.shop_comments.find(params[:id])
    @shop_comment.destroy
    redirect_to @shop, notice: 'コメントが削除されました。'
  end

  private

  def set_shop
    @shop = Shop.find(params[:shop_id])
  end

  def shop_comment_params
    params.require(:shop_comment).permit(:content, :rating)
  end
end