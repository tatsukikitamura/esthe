class CreateShopComments < ActiveRecord::Migration[7.1]
  def change
    create_table :shop_comments do |t|
      t.text :content
      t.integer :rating
      t.references :user, null: false, foreign_key: true
      t.references :shop, null: false, foreign_key: true

      t.timestamps
    end
  end
end
