class AddActiveToDeviceTokens < ActiveRecord::Migration[8.1]
  def change
    add_column :device_tokens, :active, :boolean
  end
end
