class CreateModels < ActiveRecord::Migration[5.2]
  def change
    create_table :models do |t|
      t.string :name, null: false
      t.belongs_to :maker

      t.timestamps
    end
  end
end
