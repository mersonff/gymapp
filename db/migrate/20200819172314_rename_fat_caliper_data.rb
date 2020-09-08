class RenameFatCaliperData < ActiveRecord::Migration[5.2]
  def change
    rename_table :fat_caliper_data, :skin_folds
  end
end
