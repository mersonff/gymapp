class AddWeightToMeasurements < ActiveRecord::Migration[5.2]
  def change
    add_column :measurements, :weight, :decimal
  end
end
