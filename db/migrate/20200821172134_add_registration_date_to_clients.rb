class AddRegistrationDateToClients < ActiveRecord::Migration[5.2]
  def change
    add_column :clients, :registration_date, :date
  end
end
