class AddCompanyIdToDeviceTokens < ActiveRecord::Migration[8.1]
  def change
    add_reference :device_tokens, :company, null: false, foreign_key: true
  end
end
