class ShopsController < ApplicationController
  def index
    if params[:search].present?
      @shops = ShopApiService.search_esthe_salons(params[:search])
      # ⚠️ データ構造に合わせて、必要であればデータを加工する
    else
      @shops = []
    end
  end

  def show
    # 検索パラメータを保持
    @search_query = params[:search]
    
    if params[:id].start_with?('api_')
      # APIデータの場合
      @is_api_data = true
      @place_id = params[:place_id]
      @shop_name = params[:name]
      @shop_rating = params[:rating]
      @shop_address = params[:address]
      @shop_price_level = params[:price_level]
      @user_ratings_total = params[:user_ratings_total]
      
      # 詳細情報とレビューを取得
      if @place_id.present?
        place_details = ShopApiService.get_place_details(@place_id)
        if place_details && place_details['status'] == 'OK'
          result = place_details['result']
          @shop_name = result['name'] if result['name']
          @shop_rating = result['rating'] if result['rating']
          @shop_address = result['formatted_address'] if result['formatted_address']
          @shop_price_level = result['price_level'] if result['price_level']
          @user_ratings_total = result['user_ratings_total'] if result['user_ratings_total']
          @place_reviews = result['reviews'] if result['reviews']
          @opening_hours = result['opening_hours'] if result['opening_hours']
          @photos = result['photos'] if result['photos']
          
          # DeepSeek APIでレビュー分析を実行
          if @place_reviews && @place_reviews.any?
            @ai_review_summary = DeepseekApiService.analyze_shop_reviews(
              @shop_name, 
              @shop_address, 
              @place_reviews
            )
          end
        end
      end
      
      @shop_comment = ShopComment.new if user_signed_in?
      @shop_comments = [] # APIデータにはコメント機能は使用しない
    else
      # データベースデータの場合
      @is_api_data = false
      @shop = Shop.includes(:persons, shop_comments: :user).find(params[:id])
      @shop_comment = ShopComment.new if user_signed_in?
      @shop_comments = @shop.shop_comments.order(created_at: :desc)
    end
  end
end
