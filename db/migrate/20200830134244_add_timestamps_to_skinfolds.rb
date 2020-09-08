class AddTimestampsToSkinfolds < ActiveRecord::Migration[5.2]
  def change
        add_column :skinfolds, :created_at, :timestamp
        add_column :skinfolds, :updated_at, :timestamp
  end
end
