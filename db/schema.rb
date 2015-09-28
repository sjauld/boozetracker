# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150923212934) do

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "weekly_results", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "week_id"
    t.integer  "monday_drinks"
    t.integer  "tuesday_drinks"
    t.integer  "wednesday_drinks"
    t.integer  "thursday_drinks"
    t.integer  "friday_drinks"
    t.integer  "saturday_drinks"
    t.integer  "sunday_drinks"
    t.integer  "total_drinks"
    t.integer  "dry_days"
    t.integer  "score"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "weekly_results", ["user_id"], name: "index_weekly_results_on_user_id"
  add_index "weekly_results", ["week_id"], name: "index_weekly_results_on_week_id"

  create_table "weeks", force: :cascade do |t|
    t.integer  "week_num"
    t.date     "start_date"
    t.integer  "team_dry_days"
    t.integer  "team_score"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

end
