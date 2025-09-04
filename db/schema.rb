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

ActiveRecord::Schema[8.0].define(version: 2025_09_04_215728) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "comments", force: :cascade do |t|
    t.bigint "to_do_item_id", null: false
    t.bigint "user_id", null: false
    t.string "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "text"
    t.index ["to_do_item_id"], name: "index_comments_on_to_do_item_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "to_do_items", force: :cascade do |t|
    t.string "token", null: false
    t.string "name", null: false
    t.string "status", default: "pending"
    t.date "due_date"
    t.text "description"
    t.bigint "assigned_to_id", null: false
    t.bigint "created_by_id", null: false
    t.jsonb "followers", default: []
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "estimated_duration"
    t.index ["assigned_to_id"], name: "index_to_do_items_on_assigned_to_id"
    t.index ["created_by_id"], name: "index_to_do_items_on_created_by_id"
    t.index ["due_date"], name: "index_to_do_items_on_due_date"
    t.index ["followers"], name: "index_to_do_items_on_followers", using: :gin
    t.index ["status"], name: "index_to_do_items_on_status"
    t.index ["token"], name: "index_to_do_items_on_token", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "token", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["token"], name: "index_users_on_token", unique: true
  end

  add_foreign_key "comments", "to_do_items"
  add_foreign_key "comments", "users"
  add_foreign_key "to_do_items", "users", column: "assigned_to_id"
  add_foreign_key "to_do_items", "users", column: "created_by_id"
end
