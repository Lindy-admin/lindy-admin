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

ActiveRecord::Schema.define(version: 20170615214506) do

  create_table "courses", force: :cascade do |t|
    t.string   "title",       null: false
    t.text     "description", null: false
    t.date     "start",       null: false
    t.date     "end",         null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "people", force: :cascade do |t|
    t.string   "firstname",  null: false
    t.string   "lastname",   null: false
    t.string   "email",      null: false
    t.string   "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_people_on_email", unique: true
  end

  create_table "registrations", force: :cascade do |t|
    t.integer  "person_id"
    t.integer  "course_id"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.boolean  "role",       default: false, null: false
    t.integer  "ticket_id"
    t.index ["course_id"], name: "index_registrations_on_course_id"
    t.index ["person_id", "course_id"], name: "index_registrations_on_person_id_and_course_id", unique: true
    t.index ["person_id"], name: "index_registrations_on_person_id"
    t.index ["ticket_id"], name: "index_registrations_on_ticket_id"
  end

  create_table "tickets", force: :cascade do |t|
    t.integer  "course_id"
    t.string   "label"
    t.integer  "price_cents",    default: 0,     null: false
    t.string   "price_currency", default: "EUR", null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.index ["course_id"], name: "index_tickets_on_course_id"
  end

end
