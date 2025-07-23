class ShopCommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_shop

  def create
    @shop_comment = @shop.shop_comments.build(shop_comment_params)
    @shop_comment.user = current_user
    
    if @shop_comment.save
      redirect_to shop_path(@shop), notice: 'コメントが投稿されました。'
    else
      # エラーの詳細をフラッシュメッセージに表示
      flash[:alert] = "コメントの投稿に失敗しました: #{@shop_comment.errors.full_messages.join(', ')}"
      # ビューを再描画するために必要な変数を設定
      @shop_comments = @shop.shop_comments.order(created_at: :desc)
      render 'shops/show'
    end
  end

  def destroy
    @shop_comment = current_user.shop_comments.find(params[:id])
    @shop_comment.destroy
    redirect_to shop_path(@shop), notice: 'コメントが削除されました。'
  rescue ActiveRecord::RecordNotFound
    redirect_to shop_path(@shop), alert: 'コメントが見つかりませんでした。'
  end

  private

  def set_shop
    @shop = Shop.find(params[:shop_id])
   end

  def shop_comment_params
    params.require(:shop_comment).permit(:content, :rating)
  end
end