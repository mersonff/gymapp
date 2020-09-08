class AddClientIdToMeasurements < ActiveRecord::Migration[5.2]
  def change
    add_column :measurements, :user_id, :integer
  end
end
