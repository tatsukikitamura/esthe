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
        req.params['language'] = 'ja'
      end
  
      return JSON.parse(response.body) if response.status == 200
      
      nil
    rescue StandardError => e
      Rails.logger.error "Google Places API error: #{e.message}"
      nil
    end

    # ページネーション対応の検索メソッド（最大60件取得）
    def self.search_esthe_salons_paginated(query, page = 1, per_page = 20, location = "35.6895,139.6917", radius = "5000")
      # キャッシュキーを生成（検索条件ごとにユニーク）
      cache_key = "places_textsearch:#{query}:#{location}:#{radius}:v2"

      # キャッシュから全結果を取得
      all_results = Rails.cache.read(cache_key)

      if all_results.nil?
        api_key = ENV['GOOGLE_PLACES_API_KEY']
        aggregated = []

        # 1ページ目を取得（通常の検索クエリ）
        first_response = Faraday.get(API_URL) do |req|
          req.params['query'] = query
          req.params['location'] = location
          req.params['radius'] = radius
          req.params['key'] = api_key
        end

        return nil unless first_response.status == 200
        first_result = JSON.parse(first_response.body)
        return nil unless %w[OK ZERO_RESULTS].include?(first_result['status'])

        aggregated.concat(first_result['results'] || [])
        next_page_token = first_result['next_page_token']

        # next_page_token を最大2回まで辿る（合計最大3ページ ≒ 60件）
        2.times do
          break if next_page_token.blank?

          # Googleの仕様によりnext_page_tokenが有効化されるまで少し待つ必要がある
          sleep 2

          response = Faraday.get(API_URL) do |req|
            req.params['pagetoken'] = next_page_token
            req.params['key'] = api_key
          end

          break unless response.status == 200
          result = JSON.parse(response.body)

          # 有効化待ちで INVALID_REQUEST が返る場合があるため、短い再試行を行う
          if result['status'] == 'INVALID_REQUEST'
            sleep 2
            response = Faraday.get(API_URL) do |req|
              req.params['pagetoken'] = next_page_token
              req.params['key'] = api_key
            end
            break unless response.status == 200
            result = JSON.parse(response.body)
          end

          break unless %w[OK ZERO_RESULTS].include?(result['status'])

          aggregated.concat(result['results'] || [])
          next_page_token = result['next_page_token']
        end

        # 最大60件に制限
        all_results = aggregated.first(60)

        # 結果をキャッシュに保存（5分間）
        Rails.cache.write(cache_key, all_results, expires_in: 5.minutes)
      end

      # ページネーション処理
      total_count = all_results.length
      offset = (page - 1) * per_page
      paginated_results = all_results[offset, per_page] || []

      {
        'results' => paginated_results,
        'status' => 'OK',
        'total_results' => total_count,
        'current_page' => page,
        'per_page' => per_page,
        'total_pages' => (total_count.to_f / per_page).ceil,
        'has_next_page' => page < (total_count.to_f / per_page).ceil,
        'has_prev_page' => page > 1
      }
    rescue StandardError => e
      Rails.logger.error "Google Places API paginated search error: #{e.message}"
      nil
    end

    def self.get_place_details(place_id)
      api_key = ENV['GOOGLE_PLACES_API_KEY']
      response = Faraday.get(DETAILS_URL) do |req|
        req.params['place_id'] = place_id
        req.params['fields'] = 'name,rating,user_ratings_total,reviews,formatted_address,price_level,opening_hours,photos,formatted_phone_number'
        req.params['key'] = api_key
      end

      return JSON.parse(response.body) if response.status == 200
      
      nil
    rescue StandardError => e
      Rails.logger.error "Google Places Details API error: #{e.message}"
      nil
    end

    # 遅延取得: 指定ページの20件のみを取得（最大3ページ）
    def self.search_esthe_salons_lazy(query, page = 1, per_page = 20, location = "35.6895,139.6917", radius = "5000")
      raise ArgumentError, 'per_page must be 20 for Google Places' unless per_page == 20

      api_key = ENV['GOOGLE_PLACES_API_KEY']
      normalized_query = "#{query} ショップ"

      # キャッシュキー
      base_key = "places_textsearch_lazy:#{normalized_query}:#{location}:#{radius}"
      token_page2_key = "#{base_key}:token_p2"
      token_page3_key = "#{base_key}:token_p3"

      # 1ページ取得関数
      fetch_page = lambda do |pagetoken: nil|
        response = Faraday.get(API_URL) do |req|
          if pagetoken.present?
            req.params['pagetoken'] = pagetoken
          else
            req.params['query'] = normalized_query
            req.params['location'] = location
            req.params['radius'] = radius
          end
          req.params['key'] = api_key
        end
        return nil unless response.status == 200
        result = JSON.parse(response.body)
        # next_page_token の有効化待ちに備えて簡易リトライ
        if result['status'] == 'INVALID_REQUEST' && pagetoken.present?
          sleep 2
          response = Faraday.get(API_URL) do |req|
            req.params['pagetoken'] = pagetoken
            req.params['key'] = api_key
          end
          return nil unless response.status == 200
          result = JSON.parse(response.body)
        end
        return result if %w[OK ZERO_RESULTS].include?(result['status'])
        nil
      end

      current_result = nil
      total_pages = 1

      case page.to_i
      when 1
        # 1ページ目を取得し、page2トークンをキャッシュ
        result = fetch_page.call
        return nil if result.nil?
        current_result = result
        if result['next_page_token'].present?
          Rails.cache.write(token_page2_key, result['next_page_token'], expires_in: 5.minutes)
          total_pages = 2
        end
      when 2
        # page2 トークンを使用。無ければpage1を先に取得して生成
        token_p2 = Rails.cache.read(token_page2_key)
        if token_p2.blank?
          first = fetch_page.call
          return nil if first.nil?
          token_p2 = first['next_page_token']
          Rails.cache.write(token_page2_key, token_p2, expires_in: 5.minutes) if token_p2.present?
        end
        if token_p2.present?
          result = fetch_page.call(pagetoken: token_p2)
          return nil if result.nil?
          current_result = result
          if result['next_page_token'].present?
            Rails.cache.write(token_page3_key, result['next_page_token'], expires_in: 5.minutes)
            total_pages = 3
          else
            total_pages = 2
          end
        else
          # 2ページ目が存在しない
          current_result = { 'results' => [], 'status' => 'ZERO_RESULTS' }
          total_pages = 1
        end
      when 3
        # page3 トークンを使用。無ければpage1→page2の順に事前取得して生成
        token_p3 = Rails.cache.read(token_page3_key)
        unless token_p3.present?
          # ensure token_p2
          token_p2 = Rails.cache.read(token_page2_key)
          if token_p2.blank?
            first = fetch_page.call
            return nil if first.nil?
            token_p2 = first['next_page_token']
            Rails.cache.write(token_page2_key, token_p2, expires_in: 5.minutes) if token_p2.present?
          end
          if token_p2.present?
            second = fetch_page.call(pagetoken: token_p2)
            return nil if second.nil?
            token_p3 = second['next_page_token']
            Rails.cache.write(token_page3_key, token_p3, expires_in: 5.minutes) if token_p3.present?
          end
        end
        if token_p3.present?
          result = fetch_page.call(pagetoken: token_p3)
          return nil if result.nil?
          current_result = result
          total_pages = 3
        else
          current_result = { 'results' => [], 'status' => 'ZERO_RESULTS' }
          total_pages = 2
        end
      else
        # 4ページ目以降は存在しない
        current_result = { 'results' => [], 'status' => 'ZERO_RESULTS' }
        total_pages = 3
      end

      results = current_result['results'] || []
      has_next = page.to_i < total_pages
      has_prev = page.to_i > 1 && total_pages > 1

      # 合理的な total_results を推定
      estimated_total = if has_next
        per_page * total_pages
      else
        # 最終ページとわかっている場合は、これまでの満額 + 現ページ件数
        per_page * (page.to_i - 1) + results.length
      end

      {
        'results' => results,
        'status' => current_result['status'] || 'OK',
        'total_results' => estimated_total,
        'current_page' => page,
        'per_page' => per_page,
        'total_pages' => total_pages,
        'has_next_page' => has_next,
        'has_prev_page' => has_prev
      }
    rescue StandardError => e
      Rails.logger.error "Google Places API lazy search error: #{e.message}"
      nil
    end
    # 追加: 言語やソートを指定してPlace Detailsを取得
    def self.get_place_details_with_options(place_id, reviews_sort: nil, language: 'ja')
      api_key = ENV['GOOGLE_PLACES_API_KEY']
      response = Faraday.get(DETAILS_URL) do |req|
        req.params['place_id'] = place_id
        req.params['fields'] = 'name,rating,user_ratings_total,reviews,formatted_address,price_level,opening_hours,photos,formatted_phone_number'
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