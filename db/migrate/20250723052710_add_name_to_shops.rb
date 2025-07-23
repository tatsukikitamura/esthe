class AddNameToShops < ActiveRecord::Migration[7.1]
  def change
    add_column :shops, :name, :string
  end
end
