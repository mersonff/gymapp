class ChangeSkinfoldColumnsToDecimal < ActiveRecord::Migration[8.0]
  def change
    change_column :skinfolds, :chest, :decimal, precision: 5, scale: 2, default: 0
    change_column :skinfolds, :midaxilary, :decimal, precision: 5, scale: 2, default: 0
    change_column :skinfolds, :subscapular, :decimal, precision: 5, scale: 2, default: 0
    change_column :skinfolds, :bicep, :decimal, precision: 5, scale: 2, default: 0
    change_column :skinfolds, :tricep, :decimal, precision: 5, scale: 2, default: 0
    change_column :skinfolds, :lower_back, :decimal, precision: 5, scale: 2, default: 0
    change_column :skinfolds, :abdominal, :decimal, precision: 5, scale: 2, default: 0
    change_column :skinfolds, :suprailiac, :decimal, precision: 5, scale: 2, default: 0
    change_column :skinfolds, :thigh, :decimal, precision: 5, scale: 2, default: 0
    change_column :skinfolds, :calf, :decimal, precision: 5, scale: 2, default: 0
  end
end
