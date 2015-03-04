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

ActiveRecord::Schema.define(version: 20150303231245) do

  create_table "appointments", force: :cascade do |t|
    t.string   "appointment_status"
    t.string   "athena_appointment_type"
    t.integer  "leo_provider_id",            null: false
    t.integer  "athena_provider_id"
    t.integer  "leo_patient_id",             null: false
    t.integer  "athena_patient_id"
    t.integer  "booked_by_user_id",          null: false
    t.integer  "rescheduled_appointment_id"
    t.integer  "duration",                   null: false
    t.date     "appointment_date",           null: false
    t.time     "appointment_start_time",     null: false
    t.boolean  "frozenyn"
    t.string   "leo_appointment_type"
    t.integer  "athena_appointment_type_id"
    t.integer  "family_id",                  null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "appointments", ["appointment_date"], name: "index_appointments_on_appointment_date"
  add_index "appointments", ["athena_appointment_type_id"], name: "index_appointments_on_athena_appointment_type_id"
  add_index "appointments", ["athena_patient_id"], name: "index_appointments_on_athena_patient_id"
  add_index "appointments", ["athena_provider_id"], name: "index_appointments_on_athena_provider_id"
  add_index "appointments", ["booked_by_user_id"], name: "index_appointments_on_booked_by_user_id"
  add_index "appointments", ["family_id"], name: "index_appointments_on_family_id"
  add_index "appointments", ["leo_appointment_type"], name: "index_appointments_on_leo_appointment_type"
  add_index "appointments", ["leo_patient_id"], name: "index_appointments_on_leo_patient_id"
  add_index "appointments", ["leo_provider_id"], name: "index_appointments_on_leo_provider_id"
  add_index "appointments", ["rescheduled_appointment_id"], name: "index_appointments_on_rescheduled_appointment_id"

  create_table "families", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "roles", force: :cascade do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
  add_index "roles", ["name"], name: "index_roles_on_name"

  create_table "users", force: :cascade do |t|
    t.string   "title",                  default: ""
    t.string   "first_name",             default: "", null: false
    t.string   "middle_initial",         default: ""
    t.string   "last_name",              default: "", null: false
    t.datetime "dob"
    t.string   "sex"
    t.integer  "practice_id"
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: ""
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.integer  "invitations_count",      default: 0
    t.string   "authentication_token"
    t.integer  "family_id"
  end

  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token"
  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["invitation_token"], name: "index_users_on_invitation_token", unique: true
  add_index "users", ["invitations_count"], name: "index_users_on_invitations_count"
  add_index "users", ["invited_by_id"], name: "index_users_on_invited_by_id"
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

  create_table "users_roles", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"

end
