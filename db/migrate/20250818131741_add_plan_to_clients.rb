class AddPlanToClients < ActiveRecord::Migration[8.0]
  def change
    add_reference :clients, :plan, foreign_key: true
  end
end
