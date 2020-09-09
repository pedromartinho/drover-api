class CreateCars < ActiveRecord::Migration[5.2]
  def change
    create_table :cars do |t|
      t.belongs_to :color, null: false
      t.belongs_to :model, null: false
      t.string :license_plate, null: false
      t.date :available_from
      t.decimal :price, precision: 8, scale: 2
      t.integer :year

      t.timestamps
    end
  end
end
