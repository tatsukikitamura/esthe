class ExternalComment < ApplicationRecord
  belongs_to :user
  
  validates :content, presence: true, length: { maximum: 500 }
  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :place_id, presence: true
  validates :shop_name, presence: true
end
