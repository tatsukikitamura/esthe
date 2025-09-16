class ExternalLike < ApplicationRecord
  belongs_to :user

  validates :place_id, presence: true
  validates :user_id, presence: true
  validates :place_id, uniqueness: { scope: :user_id }
end


