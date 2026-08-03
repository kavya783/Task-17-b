class AddCompanyIdToDeviceTokens < ActiveRecord::Migration[8.0]
  def change
    add_reference :device_tokens, :company, null: true, foreign_key: true
  end
end