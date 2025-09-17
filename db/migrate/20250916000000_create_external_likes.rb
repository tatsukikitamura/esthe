class CreateExternalLikes < ActiveRecord::Migration[7.0]
  def change
    create_table :external_likes do |t|
      t.references :user, null: false, foreign_key: true
      t.string :place_id, null: false
      t.string :name
      t.string :address
      t.float :rating
      t.integer :user_ratings_total
      t.timestamps
    end
    add_index :external_likes, [:user_id, :place_id], unique: true
    add_index :external_likes, :place_id
  end
end


