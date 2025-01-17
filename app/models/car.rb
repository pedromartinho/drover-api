class Car < ApplicationRecord
  # Relations
  belongs_to :color
  belongs_to :model
  has_one :maker, through: :model

  # VALIDATIONS
  validates :license_plate, presence: true, uniqueness: true
  validates :year, presence: true
  validates :price, presence: true
end
