class CreatePlans < ActiveRecord::Migration[5.2]
  def change
    create_table :plans do |t|
      t.decimal :value
      t.text :description
    end
  end
end
