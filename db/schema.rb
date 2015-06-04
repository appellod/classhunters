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

ActiveRecord::Schema.define(version: 20150528204254) do

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

  create_table "course_searches", force: true do |t|
    t.text     "search"
    t.decimal  "latitude",   precision: 15, scale: 10
    t.decimal  "longitude",  precision: 15, scale: 10
    t.string   "ip_address"
    t.integer  "school_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "course_searches", ["school_id"], name: "index_course_searches_on_school_id", using: :btree
  add_index "course_searches", ["user_id"], name: "index_course_searches_on_user_id", using: :btree

  create_table "course_searches_courses", id: false, force: true do |t|
    t.integer "course_id",        null: false
    t.integer "course_search_id", null: false
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

  create_table "emails", force: true do |t|
    t.string   "name"
    t.string   "address"
    t.integer  "school_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "emails", ["school_id"], name: "index_emails_on_school_id", using: :btree

  create_table "instructors", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "school_id"
  end

  add_index "instructors", ["school_id"], name: "index_instructors_on_school_id", using: :btree

  create_table "links", force: true do |t|
    t.string   "name"
    t.text     "url"
    t.integer  "school_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "links", ["school_id"], name: "index_links_on_school_id", using: :btree

  create_table "phone_numbers", force: true do |t|
    t.string   "name"
    t.string   "number"
    t.integer  "school_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "phone_numbers", ["school_id"], name: "index_phone_numbers_on_school_id", using: :btree

  create_table "plugin_accesses", force: true do |t|
    t.string   "remote_ip"
    t.integer  "school_id"
    t.decimal  "latitude",   precision: 15, scale: 10
    t.decimal  "longitude",  precision: 15, scale: 10
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "referer"
  end

  add_index "plugin_accesses", ["school_id"], name: "index_plugin_accesses_on_school_id", using: :btree

  create_table "school_searches", force: true do |t|
    t.string   "type"
    t.string   "search"
    t.decimal  "latitude",   precision: 15, scale: 10
    t.decimal  "longitude",  precision: 15, scale: 10
    t.string   "ip_address"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "school_searches", ["user_id"], name: "index_school_searches_on_user_id", using: :btree

  create_table "school_styles", force: true do |t|
    t.string   "foreground"
    t.string   "background"
    t.integer  "school_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "school_styles", ["school_id"], name: "index_school_styles_on_school_id", using: :btree

  create_table "schools", force: true do |t|
    t.string   "name"
    t.string   "website"
    t.string   "address"
    t.decimal  "latitude",      precision: 15, scale: 10
    t.decimal  "longitude",     precision: 15, scale: 10
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
    t.boolean  "active",                                  default: false, null: false
    t.text     "description"
    t.string   "founding_date"
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

  create_table "semesters", force: true do |t|
    t.string   "name"
    t.integer  "year"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "session_searches", force: true do |t|
    t.text     "search"
    t.decimal  "latitude",   precision: 15, scale: 10
    t.decimal  "longitude",  precision: 15, scale: 10
    t.string   "ip_address"
    t.boolean  "sunday"
    t.boolean  "monday"
    t.boolean  "tuesday"
    t.boolean  "wednesday"
    t.boolean  "thursday"
    t.boolean  "friday"
    t.boolean  "saturday"
    t.time     "start_time"
    t.time     "end_time"
    t.boolean  "classroom"
    t.boolean  "online"
    t.integer  "school_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "session_searches", ["school_id"], name: "index_session_searches_on_school_id", using: :btree
  add_index "session_searches", ["user_id"], name: "index_session_searches_on_user_id", using: :btree

  create_table "session_searches_sessions", id: false, force: true do |t|
    t.integer "session_id",        null: false
    t.integer "session_search_id", null: false
  end

  create_table "sessions", force: true do |t|
    t.boolean  "sunday",                                default: false, null: false
    t.boolean  "monday",                                default: false, null: false
    t.boolean  "tuesday",                               default: false, null: false
    t.boolean  "wednesday",                             default: false, null: false
    t.boolean  "thursday",                              default: false, null: false
    t.boolean  "friday",                                default: false, null: false
    t.boolean  "saturday",                              default: false, null: false
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
    t.boolean  "online",                                default: false, null: false
    t.integer  "semester_id"
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
