# app/services/hotpepper_service.rb

require 'httparty'

class HotpepperService
  include HTTParty
  base_uri 'http://webservice.recruit.co.jp/hotpepper/shop/v1'

  def self.search_shops(keyword)
    api_key = ENV['HOTPEPPER_API_KEY']
    
    # デバッグ情報をログに出力
    Rails.logger.info "HotpepperService: Searching for '#{keyword}'"
    Rails.logger.info "HotpepperService: API Key present: #{api_key.present?}"
    Rails.logger.info "HotpepperService: API Key length: #{api_key&.length || 0}"
    Rails.logger.info "HotpepperService: Environment: #{Rails.env}"
    
    return nil unless api_key.present?
    
    # まず店名で直接検索
    shops = search_by_name(keyword, api_key)
    
    # 結果がない場合は、キーワード検索を試行
    if shops.nil? || shops.empty?
      Rails.logger.info "HotpepperService: No results for name search, trying keyword search"
      shops = search_by_keyword(keyword, api_key)
    end
    
    shops
  end

  private

  def self.search_by_name(shop_name, api_key)
    response = get(
      '',
      query: {
        key: api_key,
        keyword: shop_name,
        format: 'json',
        count: 20
      }
    )
    
    process_response(response, "name search")
  end

  def self.search_by_keyword(keyword, api_key)
    response = get(
      '',
      query: {
        key: api_key,
        keyword: keyword,
        format: 'json',
        count: 20
      }
    )
    
    process_response(response, "keyword search")
  end

  def self.process_response(response, search_type)
    Rails.logger.info "HotpepperService: #{search_type} - Response status: #{response.code}"
    Rails.logger.info "HotpepperService: #{search_type} - Response body: #{response.body}"
    
    if response.success?
      parsed_response = JSON.parse(response.body)
      Rails.logger.info "HotpepperService: #{search_type} - Parsed response: #{parsed_response}"
      
      # エラーレスポンスのチェック
      if parsed_response['results'] && parsed_response['results']['error']
        error_info = parsed_response['results']['error']
        Rails.logger.error "HotpepperService: API Error - #{error_info['message']} (Code: #{error_info['code']})"
        return nil
      end
      
      # 成功レスポンスの処理
      if parsed_response['results'] && parsed_response['results']['shop']
        shops = parsed_response['results']['shop']
        # 配列でない場合は配列に変換
        shops = [shops] unless shops.is_a?(Array)
        Rails.logger.info "HotpepperService: #{search_type} - Found #{shops.length} shops"
        return shops
      else
        Rails.logger.warn "HotpepperService: #{search_type} - No shops found in response"
        return []
      end
    else
      Rails.logger.error "HotpepperService: #{search_type} - API request failed with status #{response.code}"
      return nil
    end
  rescue StandardError => e
    Rails.logger.error "HotpepperService: #{search_type} - Error occurred: #{e.message}"
    Rails.logger.error "HotpepperService: #{search_type} - Backtrace: #{e.backtrace.join("\n")}"
    nil
  end
end