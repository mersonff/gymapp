class AddTimestampsToClients < ActiveRecord::Migration[5.2]
  def change
    add_column :clients, :created_at, :timestamp
    add_column :clients, :updated_at, :timestamp
  end
end
