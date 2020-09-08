class AddTimestampsToPlans < ActiveRecord::Migration[5.2]
  def change
    add_column :plans, :created_at, :timestamp
    add_column :plans, :updated_at, :timestamp
  end
end
