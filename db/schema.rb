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

ActiveRecord::Schema.define(version: 20170514091516) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "articles", id: :serial, force: :cascade do |t|
    t.string "title"
    t.string "author"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "section_order"
    t.integer "user_id"
    t.integer "w_public"
    t.integer "r_public"
    t.string "language"
    t.datetime "modified_datetime"
    t.string "identifier_uuid"
    t.binary "cover_image"
    t.text "css"
    t.string "icon_base64"
    t.index ["user_id"], name: "index_articles_on_user_id"
  end

  create_table "images", force: :cascade do |t|
    t.string "name"
    t.binary "image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["name"], name: "index_images_on_name", unique: true
    t.index ["user_id"], name: "index_images_on_user_id"
  end

  create_table "notes", id: :serial, force: :cascade do |t|
    t.string "title"
    t.text "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "section_id"
    t.index ["section_id"], name: "index_notes_on_section_id"
  end

  create_table "sections", id: :serial, force: :cascade do |t|
    t.string "heading"
    t.integer "article_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "note_order"
    t.index ["article_id"], name: "index_sections_on_article_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin"
  end

  add_foreign_key "articles", "users"
  add_foreign_key "images", "users"
  add_foreign_key "notes", "sections"
  add_foreign_key "sections", "articles"
end
