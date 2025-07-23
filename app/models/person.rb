class Person < ApplicationRecord
  belongs_to :shop
  has_one_attached :profile_image
  
  validates :name, presence: true
  validates :age, presence: true, numericality: { greater_than: 0 }
end
