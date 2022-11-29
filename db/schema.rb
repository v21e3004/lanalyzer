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

ActiveRecord::Schema.define(version: 20221112013221) do

  create_table "activities", force: :cascade do |t|
    t.string   "name"
    t.integer  "activity_id"
    t.integer  "course_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.boolean  "sent_messages"
    t.index ["course_id"], name: "index_activities_on_course_id"
  end

  create_table "courses", force: :cascade do |t|
    t.string   "name"
    t.string   "course_code"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.boolean  "focus",       default: false, null: false
  end

  create_table "enrollments", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "course_id"
    t.string   "role"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.boolean  "monitoring", default: true, null: false
    t.index ["course_id"], name: "index_enrollments_on_course_id"
    t.index ["user_id"], name: "index_enrollments_on_user_id"
  end

  create_table "events", force: :cascade do |t|
    t.datetime "submitted_time"
    t.integer  "user_id"
    t.integer  "course_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "activity_id"
    t.string   "action"
    t.index ["activity_id"], name: "index_events_on_activity_id"
    t.index ["course_id"], name: "index_events_on_course_id"
    t.index ["user_id"], name: "index_events_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "name"
    t.string   "student_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
