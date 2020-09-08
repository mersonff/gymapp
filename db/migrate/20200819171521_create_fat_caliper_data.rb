class CreateFatCaliperData < ActiveRecord::Migration[5.2]
  def change
    create_table :fat_caliper_data do |t|
      t.integer :chest
      t.integer :midaxilary
      t.integer :subscapular
      t.integer :bicep
      t.integer :tricep
      t.integer :lower_back
      t.integer :abdominal
      t.integer :suprailiac
      t.integer :thigh
      t.integer :calf
      t.integer :client_id
    end
  end
end
