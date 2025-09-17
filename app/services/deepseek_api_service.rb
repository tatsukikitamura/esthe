class DeepseekApiService
  API_URL = "https://api.deepseek.com/v1/chat/completions"
  
  def self.analyze_shop_reviews(shop_name, shop_address = nil, place_reviews = [])
    api_key = ENV['DEEPSEEK_API_KEY']
    
    Rails.logger.info "DeepSeek API called for shop: #{shop_name}"
    Rails.logger.info "API Key present: #{api_key.present?}"
    Rails.logger.info "Reviews count: #{place_reviews&.length || 0}"
    
    return nil unless api_key.present?
    
    # レビューデータを整理
    review_texts = place_reviews.map { |review| 
      "#{review['author_name'] || '匿名'}: #{review['text'] || 'レビューテキストなし'} (評価: #{review['rating']})"
    }.join("\n")
    
    Rails.logger.info "Review texts length: #{review_texts.length}"
    
    # プロンプトを作成
    prompt = build_prompt(shop_name, shop_address, review_texts)
    
    response = Faraday.post(API_URL) do |req|
      req.headers['Content-Type'] = 'application/json'
      req.headers['Authorization'] = "Bearer #{api_key}"
      req.body = {
        model: "deepseek-chat",
        messages: [
          {
            role: "user",
            content: prompt
          }
        ],
        max_tokens: 500,
        temperature: 0.3
      }.to_json
    end
    
    Rails.logger.info "DeepSeek API response status: #{response.status}"
    
    if response.status == 200
      result = JSON.parse(response.body)
      Rails.logger.info "DeepSeek API response parsed successfully"
      content = result.dig('choices', 0, 'message', 'content')
      Rails.logger.info "DeepSeek API content length: #{content&.length || 0}"
      content
    else
      Rails.logger.error "DeepSeek API error: #{response.status} - #{response.body}"
      nil
    end
  rescue StandardError => e
    Rails.logger.error "DeepSeek API error: #{e.message}"
    nil
  end
  
  private
  
  def self.build_prompt(shop_name, shop_address, review_texts)
    <<~PROMPT
      以下のエステサロンの情報とGoogle Placesのレビューまたweb上での情報を分析して、ネット上の評価をまとめてください。

      【店舗情報】
      店名: #{shop_name}
      #{shop_address ? "住所: #{shop_address}" : ""}

      【Google Places レビュー】
      #{review_texts.present? ? review_texts : "レビューデータがありません"}

      【分析依頼】
      上記の情報を基に、以下の観点で分析をお願いします：

      1. **良い点**: 顧客が評価している良い点を2~3つ
      2. **注意点**: 利用前に知っておいた方が良い点
      ~~のネット評価分析のような最初の見出しは要らないです
      回答は日本語で、なるべく簡潔にお願いします。
      文字数は500文字ほどでお願いします。
      
      レビューデータが3件より少ない場合は、その旨を明記してください。
    PROMPT
  end
end
