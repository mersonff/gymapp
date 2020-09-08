class CreateClients < ActiveRecord::Migration[5.2]
  def change
    create_table :clients do |t|
      t.string :name
      t.date :bithdate
      t.text :address
      t.string :cellphone
      t.string :gender
    end
  end
end
