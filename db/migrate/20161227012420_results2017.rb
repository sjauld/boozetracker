class Results2017 < ActiveRecord::Migration[5.0]
  def change
    change_table :users do |t|
      t.integer :results_2017, null: false, default: 0
      t.boolean :admin
    end
  end
end
