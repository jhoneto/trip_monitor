# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_09_02_142249) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "companies", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_companies_on_user_id"
  end

  create_table "kitetrip_events", force: :cascade do |t|
    t.bigint "kitetrip_id", null: false
    t.datetime "event_date", null: false
    t.string "title", null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["kitetrip_id"], name: "index_kitetrip_events_on_kitetrip_id"
  end

  create_table "kitetrip_participants", force: :cascade do |t|
    t.bigint "kitetrip_id", null: false
    t.bigint "user_id", null: false
    t.string "role", default: "participant", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["kitetrip_id"], name: "index_kitetrip_participants_on_kitetrip_id"
    t.index ["user_id"], name: "index_kitetrip_participants_on_user_id"
  end

  create_table "kitetrip_routes", force: :cascade do |t|
    t.bigint "kitetrip_id", null: false
    t.datetime "start_date", null: false
    t.datetime "end_date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["kitetrip_id"], name: "index_kitetrip_routes_on_kitetrip_id"
  end

  create_table "kitetrips", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "company_id", null: false
    t.index ["company_id"], name: "index_kitetrips_on_company_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "companies", "users"
  add_foreign_key "kitetrip_events", "kitetrips"
  add_foreign_key "kitetrip_participants", "kitetrips"
  add_foreign_key "kitetrip_participants", "users"
  add_foreign_key "kitetrip_routes", "kitetrips"
  add_foreign_key "kitetrips", "companies"
end
