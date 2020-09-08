class AddTimestampsToMeasurements < ActiveRecord::Migration[5.2]
  def change
        add_column :measurements, :created_at, :timestamp
        add_column :measurements, :updated_at, :timestamp
  end
end
