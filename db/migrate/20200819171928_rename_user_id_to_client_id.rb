class RenameUserIdToClientId < ActiveRecord::Migration[5.2]
  def change
    rename_column :measurements, :user_id, :client_id
  end
end
