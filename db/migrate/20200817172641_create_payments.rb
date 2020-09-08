class CreatePayments < ActiveRecord::Migration[5.2]
  def change
    create_table :payments do |t|
      t.decimal :value
      t.date :payment_date
      t.integer :client_id
      t.timestamps
    end
  end
end
