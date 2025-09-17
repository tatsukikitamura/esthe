class Shop < ApplicationRecord
  has_many :persons, dependent: :destroy
  has_many :shop_comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :liked_users, through: :likes, source: :user
  has_one_attached :profile_image
  
  validates :name, presence: true
  
  # 平均評価を計算するメソッド
  def average_rating
    return 0 if shop_comments.empty?
    shop_comments.average(:rating)
  end
end
