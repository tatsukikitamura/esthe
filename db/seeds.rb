# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# ショップデータを追加
shops_data = [
  {
    name: "リラクゼーションサロン花",
    email: "hana@example.com",
    password: "password123"
  },
  {
    name: "ビューティーエステ美月",
    email: "mizuki@example.com", 
    password: "password123"
  },
  {
    name: "癒しの空間SAKURA",
    email: "sakura@example.com",
    password: "password123"
  },
  {
    name: "プレミアムスパ光",
    email: "hikari@example.com",
    password: "password123"
  },
  {
    name: "トータルビューティー雅",
    email: "miyabi@example.com",
    password: "password123"
  }
]

shops_data.each do |shop_data|
  Shop.find_or_create_by(email: shop_data[:email]) do |shop|
    shop.name = shop_data[:name]
    shop.password = shop_data[:password]
  end
end

puts "#{Shop.count}件のショップが作成されました。"

# Personsデータを追加
shops = Shop.all

shops.each do |shop|
  rand(2..5).times do |i|
    Person.find_or_create_by(name: "スタッフ#{i+1}", shop: shop) do |person|
      person.age = rand(20..45)
    end
  end
end

puts "#{Person.count}人のスタッフが作成されました。"
