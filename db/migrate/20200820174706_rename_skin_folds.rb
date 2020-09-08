class RenameSkinFolds < ActiveRecord::Migration[5.2]
  def change
    rename_table :skin_folds, :skinfolds
  end
end
