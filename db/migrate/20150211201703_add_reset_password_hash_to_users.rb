class AddResetPasswordHashToUsers < ActiveRecord::Migration
  def change
    add_column :users, :reset_password_hash, :string
  end
end
