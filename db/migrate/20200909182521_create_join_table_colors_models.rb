class CreateJoinTableColorsModels < ActiveRecord::Migration[5.2]
  def change
    create_join_table :colors, :models
  end
end
