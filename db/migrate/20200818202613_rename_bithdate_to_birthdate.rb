class RenameBithdateToBirthdate < ActiveRecord::Migration[5.2]
  def change
    rename_column :clients, :bithdate, :birthdate
  end
end
