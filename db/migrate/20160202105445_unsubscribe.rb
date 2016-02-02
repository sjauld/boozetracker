class Unsubscribe < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.boolean :unsubscribed
    end
  end
end
