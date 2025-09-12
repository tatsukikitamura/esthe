class ShopApiService
    API_URL = "https://maps.googleapis.com/maps/api/place/textsearch/json"
    DETAILS_URL = "https://maps.googleapis.com/maps/api/place/details/json"
  
    def self.search_esthe_salons(query, location = "35.6895,139.6917", radius = "5000") # 東京駅周辺をデフォルトとする
      api_key = ENV['GOOGLE_PLACES_API_KEY']
      response = Faraday.get(API_URL) do |req|
        req.params['query'] = "#{query} エステ" # 検索キーワードに「エステ」を追加
        req.params['location'] = location # 緯度と経度
        req.params['radius'] = radius # 検索範囲（メートル）
        req.params['key'] = api_key
      end
  
      return JSON.parse(response.body) if response.status == 200
      
      nil
    rescue StandardError => e
      Rails.logger.error "Google Places API error: #{e.message}"
      nil
    end

    def self.get_place_details(place_id)
      api_key = ENV['GOOGLE_PLACES_API_KEY']
      response = Faraday.get(DETAILS_URL) do |req|
        req.params['place_id'] = place_id
        req.params['fields'] = 'name,rating,user_ratings_total,reviews,formatted_address,price_level,opening_hours,photos'
        req.params['key'] = api_key
      end

      return JSON.parse(response.body) if response.status == 200
      
      nil
    rescue StandardError => e
      Rails.logger.error "Google Places Details API error: #{e.message}"
      nil
    end
  end