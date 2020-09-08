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

ActiveRecord::Schema.define(version: 2020_09_08_195528) do

  create_table "clients", force: :cascade do |t|
    t.string "name"
    t.date "birthdate"
    t.text "address"
    t.string "cellphone"
    t.string "gender"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "user_id"
    t.date "registration_date"
  end

  create_table "measurements", force: :cascade do |t|
    t.integer "height", default: 0
    t.integer "chest", default: 0
    t.integer "left_arm", default: 0
    t.integer "right_arm", default: 0
    t.integer "waist", default: 0
    t.integer "abdomen", default: 0
    t.integer "hips", default: 0
    t.integer "left_thigh", default: 0
    t.integer "righ_thigh", default: 0
    t.integer "client_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "weight", default: 0
  end

  create_table "payments", force: :cascade do |t|
    t.decimal "value"
    t.date "payment_date"
    t.integer "client_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "plans", force: :cascade do |t|
    t.decimal "value"
    t.text "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "user_id"
  end

  create_table "skinfolds", force: :cascade do |t|
    t.integer "chest", default: 0
    t.integer "midaxilary", default: 0
    t.integer "subscapular", default: 0
    t.integer "bicep", default: 0
    t.integer "tricep", default: 0
    t.integer "lower_back", default: 0
    t.integer "abdominal", default: 0
    t.integer "suprailiac", default: 0
    t.integer "thigh", default: 0
    t.integer "calf", default: 0
    t.integer "client_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.boolean "admin", default: false
    t.string "business_name"
  end

end
