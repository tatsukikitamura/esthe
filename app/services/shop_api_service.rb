class ShopApiService
    API_URL = "https://maps.googleapis.com/maps/api/place/textsearch/json"
    DETAILS_URL = "https://maps.googleapis.com/maps/api/place/details/json"
  
    def self.search_esthe_salons(query, location = "35.6895,139.6917", radius = "5000") # 東京駅周辺をデフォルトとする
      api_key = ENV['GOOGLE_PLACES_API_KEY']
      response = Faraday.get(API_URL) do |req|
        req.params['query'] = "#{query} ショップ" # 検索キーワードに「エステ」を追加
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

    # 追加: 言語やソートを指定してPlace Detailsを取得
    def self.get_place_details_with_options(place_id, reviews_sort: nil, language: 'ja')
      api_key = ENV['GOOGLE_PLACES_API_KEY']
      response = Faraday.get(DETAILS_URL) do |req|
        req.params['place_id'] = place_id
        req.params['fields'] = 'name,rating,user_ratings_total,reviews,formatted_address,price_level,opening_hours,photos'
        req.params['language'] = language if language
        req.params['reviews_sort'] = reviews_sort if reviews_sort
        req.params['key'] = api_key
      end

      return JSON.parse(response.body) if response.status == 200

      nil
    rescue StandardError => e
      Rails.logger.error "Google Places Details API (options) error: #{e.message}"
      nil
    end

    # 追加: 複数ソート・複数言語でレビューをマージして返す
    def self.get_place_reviews_merged(place_id)
      # 日本語の最新順・関連度順
      newest_ja = get_place_details_with_options(place_id, reviews_sort: 'newest', language: 'ja')
      relevant_ja = get_place_details_with_options(place_id, reviews_sort: 'most_relevant', language: 'ja')

      reviews = []
      reviews += newest_ja&.dig('result', 'reviews') || []
      reviews += relevant_ja&.dig('result', 'reviews') || []

      # 日本語が少ない場合、英語も補完
      if reviews.length < 10
        newest_en = get_place_details_with_options(place_id, reviews_sort: 'newest', language: 'en')
        relevant_en = get_place_details_with_options(place_id, reviews_sort: 'most_relevant', language: 'en')
        reviews += newest_en&.dig('result', 'reviews') || []
        reviews += relevant_en&.dig('result', 'reviews') || []
      end

      # 重複排除（著者名・時間・評価・本文の組合せ）
      seen = {}
      merged = []
      reviews.each do |r|
        key = [r['author_name'], r['time'], r['rating'], r['text']].join('|')
        next if seen[key]
        seen[key] = true
        merged << r
      end

      merged
    rescue StandardError => e
      Rails.logger.error "Google Places Reviews merge error: #{e.message}"
      []
    end
  end