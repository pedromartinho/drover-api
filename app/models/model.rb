class Model < ApplicationRecord
  # RELATIONS
  belongs_to :maker
  has_many :cars
  has_and_belongs_to_many :colors

  # VALIDATIONS
  validates :name, presence: true, uniqueness: true
end
