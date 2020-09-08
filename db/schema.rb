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

ActiveRecord::Schema.define(version: 2020_09_02_200826) do

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
    t.integer "height"
    t.integer "chest"
    t.integer "left_arm"
    t.integer "right_arm"
    t.integer "waist"
    t.integer "abdomen"
    t.integer "hips"
    t.integer "left_thigh"
    t.integer "righ_thigh"
    t.integer "client_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "weight"
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
    t.integer "chest"
    t.integer "midaxilary"
    t.integer "subscapular"
    t.integer "bicep"
    t.integer "tricep"
    t.integer "lower_back"
    t.integer "abdominal"
    t.integer "suprailiac"
    t.integer "thigh"
    t.integer "calf"
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
