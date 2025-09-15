class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one_attached :profile_image
  has_many :shop_comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :liked_shops, through: :likes, source: :shop

  validates :name, presence: true
end
