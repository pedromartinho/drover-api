class Maker < ApplicationRecord
  # RELATIONS
  has_many :models

  # VALIDATIONS
  validates :name, presence: true, uniqueness: true
end
