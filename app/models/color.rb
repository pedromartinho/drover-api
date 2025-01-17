class Color < ApplicationRecord
  # RELATIONS
  has_many :cars
  has_and_belongs_to_many :models

  # VALIDATIONS
  validates :name, presence: true, uniqueness: true
end
