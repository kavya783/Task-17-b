class AddPerformanceIndexesToLeaves < ActiveRecord::Migration[8.1]
  def change
    add_index :leaves,
              [:leaveable_type, :leaveable_id, :created_at],
              name: "index_leaves_on_leaveable_and_created_at"

    add_index :leaves,
              [:company_id, :created_at],
              name: "index_leaves_on_company_and_created_at"
  end
end