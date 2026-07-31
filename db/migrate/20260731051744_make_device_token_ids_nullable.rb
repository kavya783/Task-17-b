class MakeDeviceTokenIdsNullable < ActiveRecord::Migration[8.1]
  def change
    change_column_null :device_tokens, :user_id, true
    change_column_null :device_tokens, :company_id, true
  end
end