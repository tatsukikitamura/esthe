namespace :mock_data do
  desc "Create mock review data for testing"
  task create_reviews: :environment do
    puts "Creating mock review data..."
    
    # ユーザーが存在しない場合は作成
    if User.count == 0
      puts "Creating test users..."
      users = []
      5.times do |i|
        user = User.create!(
          name: "テストユーザー#{i + 1}",
          email: "test#{i + 1}@example.com",
          password: "password123",
          password_confirmation: "password123"
        )
        users << user
        puts "Created user: #{user.name} (#{user.email})"
      end
    else
      users = User.limit(5).to_a
      puts "Using existing users: #{users.map(&:name).join(', ')}"
    end
    
    # ショップが存在しない場合は作成
    if Shop.count == 0
      puts "Creating test shops..."
      shops = []
      3.times do |i|
        shop = Shop.create!(
          name: "エステサロン#{i + 1}",
          email: "shop#{i + 1}@example.com"
        )
        shops << shop
        puts "Created shop: #{shop.name}"
      end
    else
      shops = Shop.limit(3).to_a
      puts "Using existing shops: #{shops.map(&:name).join(', ')}"
    end
    
    # ショップコメント（データベース用）のモックデータを作成
    puts "\nCreating shop comments..."
    shop_comments_data = [
      {
        content: "とてもリラックスできました。スタッフの方も親切で、技術も素晴らしかったです。また利用したいと思います。",
        rating: 5
      },
      {
        content: "初回利用でしたが、丁寧な説明と心地よい施術で満足しています。料金もリーズナブルで良かったです。",
        rating: 4
      },
      {
        content: "設備が新しく、清潔感がありました。施術後の肌の調子も良く、効果を実感できました。",
        rating: 5
      },
      {
        content: "予約が取りにくいのが難点ですが、それだけ人気があるということですね。施術は期待通りでした。",
        rating: 4
      },
      {
        content: "スタッフの対応は良かったのですが、施術時間が短く感じました。もう少し時間をかけてほしいです。",
        rating: 3
      },
      {
        content: "立地が良く、アクセスしやすい場所にあります。施術も丁寧で、リピートしたいと思います。",
        rating: 4
      },
      {
        content: "料金は少し高めですが、その分の価値はあると思います。特別な日のお手入れに最適です。",
        rating: 5
      },
      {
        content: "予約の変更が柔軟に対応してもらえて助かりました。施術も期待以上でした。",
        rating: 5
      },
      {
        content: "店内の雰囲気が落ち着いていて、リラックスできました。また利用したいです。",
        rating: 4
      },
      {
        content: "初回割引があったので利用しましたが、通常料金でも通いたいと思える良いサロンでした。",
        rating: 5
      }
    ]
    
    shops.each_with_index do |shop, shop_index|
      # 各ショップに3-4個のコメントを作成
      comment_count = rand(3..4)
      comment_count.times do |i|
        comment_data = shop_comments_data.sample
        user = users.sample
        
        shop_comment = shop.shop_comments.create!(
          user: user,
          content: comment_data[:content],
          rating: comment_data[:rating]
        )
        puts "Created shop comment for #{shop.name}: #{comment_data[:rating]}★ by #{user.name}"
      end
    end
    
    # 外部コメント（APIデータ用）のモックデータを作成
    puts "\nCreating external comments..."
    external_comments_data = [
      {
        place_id: "ChIJaU06eYODImARkWe4J9w6_i4",
        shop_name: "Perie Inage",
        shop_address: "3-chōme-19-11 Inagehigashi, Inage Ward, Chiba, 263-0031, Japan",
        content: "Google Placesで見つけたサロンですが、予想以上に良かったです。スタッフの技術が高く、リラックスできました。",
        rating: 5
      },
      {
        place_id: "ChIJaU06eYODImARkWe4J9w6_i4",
        shop_name: "Perie Inage",
        shop_address: "3-chōme-19-11 Inagehigashi, Inage Ward, Chiba, 263-0031, Japan",
        content: "アクセスが良く、駅から近いので通いやすいです。施術も丁寧で満足しています。",
        rating: 4
      },
      {
        place_id: "ChIJaU06eYODImARkWe4J9w6_i4",
        shop_name: "Perie Inage",
        shop_address: "3-chōme-19-11 Inagehigashi, Inage Ward, Chiba, 263-0031, Japan",
        content: "初回利用でしたが、説明が分かりやすく安心して施術を受けられました。また利用したいです。",
        rating: 5
      },
      {
        place_id: "ChIJbX8X8YODImARkWe4J9w6_i5",
        shop_name: "エステサロン 美肌",
        shop_address: "東京都渋谷区道玄坂1-2-3",
        content: "渋谷の中心部にあるサロンで、お買い物のついでに利用できます。施術も満足でした。",
        rating: 4
      },
      {
        place_id: "ChIJbX8X8YODImARkWe4J9w6_i5",
        shop_name: "エステサロン 美肌",
        shop_address: "東京都渋谷区道玄坂1-2-3",
        content: "料金がリーズナブルで、学生でも利用しやすい価格設定になっています。",
        rating: 4
      },
      {
        place_id: "ChIJcX9X9YODImARkWe4J9w6_i6",
        shop_name: "リラクゼーション サロン",
        shop_address: "大阪府大阪市北区梅田1-1-1",
        content: "大阪の梅田にあるサロンです。ビジネス街なので、仕事帰りに利用するのに便利です。",
        rating: 5
      },
      {
        place_id: "ChIJcX9X9YODImARkWe4J9w6_i6",
        shop_name: "リラクゼーション サロン",
        shop_address: "大阪府大阪市北区梅田1-1-1",
        content: "設備が新しく、清潔感があります。スタッフの対応も丁寧で良かったです。",
        rating: 4
      },
      {
        place_id: "ChIJdX0X0YODImARkWe4J9w6_i7",
        shop_name: "スパ リゾート",
        shop_address: "神奈川県横浜市西区みなとみらい2-2-2",
        content: "みなとみらいの高層ビルにあるサロンで、夜景が綺麗です。特別な日のお手入れに最適。",
        rating: 5
      },
      {
        place_id: "ChIJdX0X0YODImARkWe4J9w6_i7",
        shop_name: "スパ リゾート",
        shop_address: "神奈川県横浜市西区みなとみらい2-2-2",
        content: "予約が取りにくいですが、それだけ人気があるということですね。施術は期待通りでした。",
        rating: 4
      },
      {
        place_id: "ChIJeX1X1YODImARkWe4J9w6_i8",
        shop_name: "エステティック サロン",
        shop_address: "愛知県名古屋市中区栄1-1-1",
        content: "名古屋の栄にあるサロンです。地下鉄のアクセスが良く、通いやすい立地です。",
        rating: 4
      }
    ]
    
    external_comments_data.each do |comment_data|
      user = users.sample
      
      external_comment = ExternalComment.create!(
        user: user,
        place_id: comment_data[:place_id],
        shop_name: comment_data[:shop_name],
        shop_address: comment_data[:shop_address],
        content: comment_data[:content],
        rating: comment_data[:rating]
      )
      puts "Created external comment for #{comment_data[:shop_name]}: #{comment_data[:rating]}★ by #{user.name}"
    end
    
    puts "\n=== Mock data creation completed ==="
    puts "Shop comments created: #{ShopComment.count}"
    puts "External comments created: #{ExternalComment.count}"
    puts "Total users: #{User.count}"
    puts "Total shops: #{Shop.count}"
  end
  
  desc "Clear all mock review data"
  task clear_reviews: :environment do
    puts "Clearing mock review data..."
    
    ShopComment.destroy_all
    ExternalComment.destroy_all
    
    puts "All review data cleared."
  end
  
  desc "Reset and recreate all mock data"
  task reset: :environment do
    puts "Resetting all mock data..."
    Rake::Task['mock_data:clear_reviews'].invoke
    Rake::Task['mock_data:create_reviews'].invoke
  end
end