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

ActiveRecord::Schema.define(version: 20150630181940) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "allergies", force: :cascade do |t|
    t.integer  "patient_id"
    t.integer  "athena_id",  default: 0,  null: false
    t.string   "allergen",   default: "", null: false
    t.datetime "onset_at"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "allergies", ["athena_id"], name: "index_allergies_on_athena_id", using: :btree
  add_index "allergies", ["patient_id"], name: "index_allergies_on_patient_id", using: :btree

  create_table "appointments", force: :cascade do |t|
    t.string   "appointment_status",         default: "o", null: false
    t.string   "athena_appointment_type"
    t.integer  "leo_provider_id",                          null: false
    t.integer  "athena_provider_id",         default: 0,   null: false
    t.integer  "leo_patient_id",                           null: false
    t.integer  "booked_by_user_id",                        null: false
    t.integer  "rescheduled_appointment_id"
    t.integer  "duration",                                 null: false
    t.date     "appointment_date",                         null: false
    t.time     "appointment_start_time",                   null: false
    t.boolean  "frozenyn"
    t.string   "leo_appointment_type"
    t.integer  "athena_appointment_type_id", default: 0,   null: false
    t.integer  "family_id",                                null: false
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.integer  "athena_id",                  default: 0,   null: false
    t.integer  "athena_department_id",       default: 0,   null: false
    t.datetime "sync_updated_at"
  end

  add_index "appointments", ["appointment_date"], name: "index_appointments_on_appointment_date", using: :btree
  add_index "appointments", ["athena_appointment_type_id"], name: "index_appointments_on_athena_appointment_type_id", using: :btree
  add_index "appointments", ["athena_department_id"], name: "index_appointments_on_athena_department_id", using: :btree
  add_index "appointments", ["athena_id"], name: "index_appointments_on_athena_id", using: :btree
  add_index "appointments", ["athena_provider_id"], name: "index_appointments_on_athena_provider_id", using: :btree
  add_index "appointments", ["booked_by_user_id"], name: "index_appointments_on_booked_by_user_id", using: :btree
  add_index "appointments", ["family_id"], name: "index_appointments_on_family_id", using: :btree
  add_index "appointments", ["leo_appointment_type"], name: "index_appointments_on_leo_appointment_type", using: :btree
  add_index "appointments", ["leo_patient_id"], name: "index_appointments_on_leo_patient_id", using: :btree
  add_index "appointments", ["leo_provider_id"], name: "index_appointments_on_leo_provider_id", using: :btree
  add_index "appointments", ["rescheduled_appointment_id"], name: "index_appointments_on_rescheduled_appointment_id", using: :btree

  create_table "conversations", force: :cascade do |t|
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.integer  "family_id"
    t.datetime "last_message_created"
    t.boolean  "archived"
    t.datetime "archived_at"
    t.integer  "archived_by_id"
  end

  create_table "conversations_participants", id: false, force: :cascade do |t|
    t.integer "conversation_id"
    t.integer "participant_id"
    t.string  "participant_role"
  end

  add_index "conversations_participants", ["conversation_id", "participant_id"], name: "conversations_participants_convid_pid", unique: true, using: :btree
  add_index "conversations_participants", ["participant_id", "conversation_id"], name: "conversations_participants_pid_convid", unique: true, using: :btree

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "families", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "insurances", force: :cascade do |t|
    t.integer  "athena_id",          default: 0, null: false
    t.string   "plan_name"
    t.string   "plan_phone"
    t.string   "plan_type"
    t.string   "policy_number"
    t.string   "holder_ssn"
    t.datetime "holder_dob"
    t.string   "holder_sex"
    t.string   "holder_last_name"
    t.string   "holder_first_name"
    t.string   "holder_middle_name"
    t.string   "holder_address_1"
    t.string   "holder_address_2"
    t.string   "holder_city"
    t.string   "holder_state"
    t.string   "holder_zip"
    t.string   "holder_country"
    t.integer  "primary"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.integer  "patient_id"
  end

  add_index "insurances", ["athena_id"], name: "index_insurances_on_athena_id", using: :btree
  add_index "insurances", ["patient_id"], name: "index_insurances_on_patient_id", using: :btree

  create_table "medications", force: :cascade do |t|
    t.integer  "patient_id"
    t.integer  "athena_id",    default: 0,  null: false
    t.string   "medication",   default: "", null: false
    t.string   "sig",          default: "", null: false
    t.string   "patient_note", default: "", null: false
    t.datetime "started_at"
    t.datetime "ended_at"
    t.datetime "ordered_at"
    t.datetime "filled_at"
    t.datetime "entered_at"
    t.datetime "hidden_at"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "medications", ["athena_id"], name: "index_medications_on_athena_id", using: :btree
  add_index "medications", ["patient_id"], name: "index_medications_on_patient_id", using: :btree

  create_table "messages", force: :cascade do |t|
    t.integer  "sender_id"
    t.integer  "conversation_id"
    t.text     "body"
    t.string   "message_type"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.integer  "escalated_to_id"
    t.datetime "resolved_requested_at"
    t.datetime "resolved_approved_at"
    t.datetime "escalated_at"
    t.integer  "escalated_by_id"
  end

  create_table "patients", force: :cascade do |t|
    t.integer  "athena_id",              default: 0, null: false
    t.integer  "user_id"
    t.datetime "patient_updated_at"
    t.datetime "medications_updated_at"
    t.datetime "vaccines_updated_at"
    t.datetime "allergies_updated_at"
    t.datetime "vitals_updated_at"
    t.datetime "insurances_updated_at"
    t.datetime "photos_updated_at"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  add_index "patients", ["athena_id"], name: "index_patients_on_athena_id", using: :btree
  add_index "patients", ["user_id"], name: "index_patients_on_user_id", using: :btree

  create_table "photos", force: :cascade do |t|
    t.integer  "patient_id"
    t.text     "image"
    t.datetime "taken_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "photos", ["patient_id"], name: "index_photos_on_patient_id", using: :btree

  create_table "read_receipts", force: :cascade do |t|
    t.integer  "message_id"
    t.string   "participant_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "roles", force: :cascade do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", using: :btree
  add_index "roles", ["name"], name: "index_roles_on_name", using: :btree

  create_table "sessions", force: :cascade do |t|
    t.integer  "user_id",              null: false
    t.string   "authentication_token", null: false
    t.datetime "disabled_at"
    t.string   "os_version"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "sessions", ["authentication_token"], name: "index_sessions_on_authentication_token", using: :btree
  add_index "sessions", ["user_id"], name: "index_sessions_on_user_id", using: :btree

  create_table "sync_tasks", force: :cascade do |t|
    t.integer  "sync_id",    default: 0,  null: false
    t.string   "sync_type",  default: "", null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "sync_tasks", ["sync_id"], name: "index_sync_tasks_on_sync_id", using: :btree
  add_index "sync_tasks", ["sync_type"], name: "index_sync_tasks_on_sync_type", using: :btree

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
    t.string   "stripe_customer_id"
  end

  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["invitation_token"], name: "index_users_on_invitation_token", unique: true, using: :btree
  add_index "users", ["invitations_count"], name: "index_users_on_invitations_count", using: :btree
  add_index "users", ["invited_by_id"], name: "index_users_on_invited_by_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "users_roles", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id", using: :btree

  create_table "vaccines", force: :cascade do |t|
    t.integer  "patient_id"
    t.string   "athena_id",       default: "", null: false
    t.string   "vaccine",         default: "", null: false
    t.datetime "administered_at"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "vaccines", ["athena_id"], name: "index_vaccines_on_athena_id", using: :btree
  add_index "vaccines", ["patient_id"], name: "index_vaccines_on_patient_id", using: :btree

  create_table "vitals", force: :cascade do |t|
    t.integer  "patient_id"
    t.integer  "athena_id",   default: 0,  null: false
    t.datetime "taken_at"
    t.string   "measurement", default: "", null: false
    t.string   "value",       default: "", null: false
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "vitals", ["athena_id"], name: "index_vitals_on_athena_id", using: :btree
  add_index "vitals", ["patient_id"], name: "index_vitals_on_patient_id", using: :btree

end
