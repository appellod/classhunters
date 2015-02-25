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

ActiveRecord::Schema.define(version: 20150220203625) do

  create_table "cities", force: true do |t|
    t.string   "zip"
    t.string   "state"
    t.string   "city"
    t.decimal  "latitude",   precision: 15, scale: 10
    t.decimal  "longitude",  precision: 15, scale: 10
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cities", ["zip", "state", "city"], name: "index_cities_on_zip_and_state_and_city", unique: true, using: :btree

  create_table "contacts", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "school"
    t.string   "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "courses", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "department"
    t.integer  "number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "school_id"
  end

  create_table "courses_users", id: false, force: true do |t|
    t.integer "course_id"
    t.integer "user_id"
  end

  create_table "instructors", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "school_id"
  end

  add_index "instructors", ["school_id"], name: "index_instructors_on_school_id", using: :btree

  create_table "schools", force: true do |t|
    t.string   "name"
    t.string   "website"
    t.string   "address"
    t.decimal  "latitude",   precision: 15, scale: 10
    t.decimal  "longitude",  precision: 15, scale: 10
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "phone"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "url"
    t.string   "category"
    t.date     "start_date"
    t.date     "end_date"
  end

  add_index "schools", ["name"], name: "index_schools_on_name", unique: true, using: :btree
  add_index "schools", ["url"], name: "index_schools_on_url", unique: true, using: :btree

  create_table "schools_users", id: false, force: true do |t|
    t.integer "school_id"
    t.integer "user_id"
  end

  create_table "searches", force: true do |t|
    t.string   "input"
    t.string   "remote_ip"
    t.string   "page"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", force: true do |t|
    t.boolean  "sunday"
    t.boolean  "monday"
    t.boolean  "tuesday"
    t.boolean  "wednesday"
    t.boolean  "thursday"
    t.boolean  "friday"
    t.boolean  "saturday"
    t.time     "start_time"
    t.time     "end_time"
    t.integer  "course_id"
    t.integer  "instructor_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "room"
    t.string   "location"
    t.integer  "crn"
    t.decimal  "credits",       precision: 4, scale: 2
    t.string   "semester"
    t.boolean  "online"
  end

  add_index "sessions", ["course_id"], name: "index_sessions_on_course_id", using: :btree
  add_index "sessions", ["instructor_id"], name: "index_sessions_on_instructor_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "password_digest"
    t.string   "remember_token"
    t.boolean  "admin",               default: false
    t.string   "reset_password_hash"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["remember_token"], name: "index_users_on_remember_token", using: :btree

  create_table "visits", force: true do |t|
    t.string   "remote_ip"
    t.string   "referrer"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "latitude",   precision: 10, scale: 0
    t.decimal  "longitude",  precision: 10, scale: 0
  end

end
