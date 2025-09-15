class Like < ApplicationRecord
  belongs_to :user
  belongs_to :shop

  validates :user_id, presence: true
  validates :shop_id, presence: true
  validates :shop_id, uniqueness: { scope: :user_id }
end



