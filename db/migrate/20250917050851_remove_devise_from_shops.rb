class RemoveDeviseFromShops < ActiveRecord::Migration[7.1]
  def change
    remove_column :shops, :encrypted_password, :string
    remove_column :shops, :reset_password_token, :string
    remove_column :shops, :reset_password_sent_at, :datetime
    remove_column :shops, :remember_created_at, :datetime
  end
end
