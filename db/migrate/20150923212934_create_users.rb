class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :first_name
      t.string :last_name
      t.string :image
      t.timestamps null: false
    end

    create_table :weeks do |t|
      t.integer :week_num
      t.date :start_date
      t.integer :team_dry_days
      t.integer :team_score
      t.timestamps null: false
    end

    create_table :weekly_results do |t|
      t.belongs_to :user, index: true
      t.belongs_to :week, index: true
      t.integer :monday_drinks
      t.integer :tuesday_drinks
      t.integer :wednesday_drinks
      t.integer :thursday_drinks
      t.integer :friday_drinks
      t.integer :saturday_drinks
      t.integer :sunday_drinks
      t.integer :total_drinks
      t.integer :dry_days
      t.integer :score
      t.timestamps null:false
    end
  end
end
