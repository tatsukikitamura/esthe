class Shop < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :persons, dependent: :destroy
  has_many :shop_comments, dependent: :destroy
  has_one_attached :profile_image
  
  validates :name, presence: true
  
  # 平均評価を計算するメソッド
  def average_rating
    return 0 if shop_comments.empty?
    shop_comments.average(:rating).round(1)
  end
end
