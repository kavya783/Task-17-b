class RemoveDuplicateDeviceTokens < ActiveRecord::Migration[8.1]
  def up
    execute <<-SQL
      DELETE FROM device_tokens
      WHERE id NOT IN (
        SELECT MIN(id)
        FROM device_tokens
        GROUP BY user_id
      );
    SQL
  end

  def down
  end
end