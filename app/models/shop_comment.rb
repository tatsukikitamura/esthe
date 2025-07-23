class ShopComment < ApplicationRecord
  belongs_to :user
  belongs_to :shop
  
  validates :content,presence: true,  length: { maximum: 500 }
  validates :rating, presence: true, inclusion: { in: 1..5 }
end
