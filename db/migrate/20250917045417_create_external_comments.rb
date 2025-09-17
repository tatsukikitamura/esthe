class CreateExternalComments < ActiveRecord::Migration[7.1]
  def change
    create_table :external_comments do |t|
      t.references :user, null: false, foreign_key: true
      t.string :place_id
      t.string :shop_name
      t.string :shop_address
      t.integer :rating
      t.text :content

      t.timestamps
    end
  end
end
