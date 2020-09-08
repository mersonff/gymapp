class CreateMeasurements < ActiveRecord::Migration[5.2]
  def change
    create_table :measurements do |t|
      t.integer :height
      t.integer :chest
      t.integer :left_arm
      t.integer :right_arm
      t.integer :waist
      t.integer :abdomen
      t.integer :hips
      t.integer :left_thigh
      t.integer :righ_thigh
    end
  end
end
