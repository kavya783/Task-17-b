class MakeUserIdUniqueInDeviceTokens < ActiveRecord::Migration[8.1]
  def change
    add_index :device_tokens, :user_id, unique: true
  end
end