class ExternalCommentsController < ApplicationController
  before_action :authenticate_user!
  
  def create
    @external_comment = current_user.external_comments.build(external_comment_params)
    
    if @external_comment.save
      redirect_to shop_path(id: "api_#{params[:comment][:place_id]}", 
                           place_id: params[:comment][:place_id],
                           name: params[:comment][:shop_name],
                           address: params[:comment][:shop_address],
                           rating: params[:comment][:rating],
                           user_ratings_total: params[:comment][:user_ratings_total]),
                  notice: 'コメントを投稿しました。'
    else
      redirect_to shop_path(id: "api_#{params[:comment][:place_id]}", 
                           place_id: params[:comment][:place_id],
                           name: params[:comment][:shop_name],
                           address: params[:comment][:shop_address],
                           rating: params[:comment][:rating],
                           user_ratings_total: params[:comment][:user_ratings_total]),
                  alert: 'コメントの投稿に失敗しました。'
    end
  end

  def destroy
    @external_comment = current_user.external_comments.find(params[:id])
    place_id = @external_comment.place_id
    shop_name = @external_comment.shop_name
    shop_address = @external_comment.shop_address
    
    @external_comment.destroy
    
    redirect_to shop_path(id: "api_#{place_id}", 
                         place_id: place_id,
                         name: shop_name,
                         address: shop_address),
                notice: 'コメントを削除しました。'
  end
  
  private
  
  def external_comment_params
    params.require(:comment).permit(:place_id, :shop_name, :shop_address, :rating, :content)
  end
end
