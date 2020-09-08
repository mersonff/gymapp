class AddDefaultValueToSkinfoldsAndMeasurements < ActiveRecord::Migration[5.2]
  def change
    change_column :skinfolds, :chest, :integer, :default => 0
    change_column :skinfolds, :midaxilary, :integer, :default => 0
    change_column :skinfolds, :subscapular, :integer, :default => 0
    change_column :skinfolds, :bicep, :integer, :default => 0
    change_column :skinfolds, :tricep, :integer, :default => 0
    change_column :skinfolds, :lower_back, :integer, :default => 0
    change_column :skinfolds, :abdominal, :integer, :default => 0
    change_column :skinfolds, :suprailiac, :integer, :default => 0
    change_column :skinfolds, :thigh, :integer, :default => 0
    change_column :skinfolds, :calf, :integer, :default => 0
    
    change_column :measurements, :height, :integer, :default => 0
    change_column :measurements, :weight, :integer, :default=> 0
    change_column :measurements, :chest, :integer, :default => 0
    change_column :measurements, :left_arm, :integer, :default => 0
    change_column :measurements, :right_arm, :integer, :default => 0
    change_column :measurements, :waist, :integer, :default => 0
    change_column :measurements, :abdomen, :integer, :default => 0
    change_column :measurements, :hips, :integer, :default => 0
    change_column :measurements, :left_thigh, :integer, :default => 0
    change_column :measurements, :righ_thigh, :integer, :default => 0
  end
end
