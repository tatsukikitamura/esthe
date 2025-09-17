class ShopsController < ApplicationController
  def search
    # 検索未実行の初期表示用。index と同じビュー構成に合わせるためのフラグのみ設定
    @shops = []
    @has_searched = false
    render :search
  end
  def index
    if params[:search].present?
      # ページネーション対応の検索（遅延取得: 指定ページの20件のみ）
      page = params[:page]&.to_i || 1
      per_page = 20
      
      @search_result = ShopApiService.search_esthe_salons_lazy(
        params[:search], 
        page, 
        per_page
      )
      
      if @search_result
        @shops = @search_result
        @has_searched = true
        @current_page = page
        @per_page = per_page
      else
        @shops = nil
        @has_searched = true
      end
    else
      @shops = []
      @has_searched = false
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
          @phone_number = result['formatted_phone_number'] if result['formatted_phone_number']
          # ここではAI分析を自動実行しない（ボタン押下時に非同期で実行）
        end
      end
      
      # Hotpepperからの情報を取得
      if @shop_name.present?
        begin
          @hotpepper_shops = HotpepperService.search_shops(@shop_name)
          # フォールバック検索が使用されたかどうかを判定
          @hotpepper_fallback_search = @hotpepper_shops.present? && @hotpepper_shops.any? do |shop|
            # 店名に完全一致するものがない場合はフォールバック検索とみなす
            shop['name'] && !shop['name'].downcase.include?(@shop_name.downcase)
          end
        rescue => e
          Rails.logger.error "Hotpepper API error: #{e.message}"
          @hotpepper_shops = nil
          @hotpepper_fallback_search = false
        end
      end
      
      @shop_comment = ShopComment.new if user_signed_in?
      # APIデータ用のexternal_commentsを取得
      @external_comments = ExternalComment.where(place_id: @place_id).includes(:user).order(created_at: :desc) if @place_id.present?
    else
      # データベースデータの場合
      @is_api_data = false
      @shop = Shop.includes(:persons, shop_comments: :user).find(params[:id])
      
      # Hotpepperからの情報を取得
      if @shop.name.present?
        begin
          @hotpepper_shops = HotpepperService.search_shops(@shop.name)
          # フォールバック検索が使用されたかどうかを判定
          @hotpepper_fallback_search = @hotpepper_shops.present? && @hotpepper_shops.any? do |shop|
            # 店名に完全一致するものがない場合はフォールバック検索とみなす
            shop['name'] && !shop['name'].downcase.include?(@shop.name.downcase)
          end
        rescue => e
          Rails.logger.error "Hotpepper API error: #{e.message}"
          @hotpepper_shops = nil
          @hotpepper_fallback_search = false
        end
      end
      
      @shop_comment = ShopComment.new if user_signed_in?
      @shop_comments = @shop.shop_comments.order(created_at: :desc)
    end
  end

  def analyze_ai
    if params[:id].start_with?('api_')
      @place_id = params[:place_id]
      @shop_name = params[:name]
      @shop_address = params[:address]
      
      # レビューを再取得
      merged_reviews = ShopApiService.get_place_reviews_merged(@place_id)
      
      if merged_reviews.any?
        @ai_review_summary = DeepseekApiService.analyze_shop_reviews(
          @shop_name, 
          @shop_address, 
          merged_reviews
        )
        
        if @ai_review_summary.present?
          summary_html = ApplicationController.helpers.render_markdown(@ai_review_summary)
          render json: { 
            success: true, 
            summary_html: summary_html 
          }
        else
          render json: { 
            success: false, 
            error: "AI分析に失敗しました。APIキーまたはネットワークを確認してください。" 
          }
        end
      else
        render json: { 
          success: false, 
          error: "レビューデータが見つかりませんでした。" 
        }
      end
    else
      render json: { 
        success: false, 
        error: "この機能はAPIデータでのみ利用可能です。" 
      }
    end
  rescue StandardError => e
    Rails.logger.error "AI analysis error: #{e.message}"
    render json: { 
      success: false, 
      error: "予期しないエラーが発生しました: #{e.message}" 
    }
  end
end
