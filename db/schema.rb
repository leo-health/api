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

ActiveRecord::Schema.define(version: 20150921010950) do

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

  create_table "appointment_statuses", force: :cascade do |t|
    t.string "description"
    t.string "status"
  end

  create_table "appointment_types", force: :cascade do |t|
    t.integer  "athena_id",         default: 0, null: false
    t.integer  "duration",                      null: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.string   "short_description"
    t.string   "long_description"
    t.string   "name",                          null: false
  end

  add_index "appointment_types", ["athena_id"], name: "index_appointment_types_on_athena_id", using: :btree

  create_table "appointments", force: :cascade do |t|
    t.integer  "duration",                          null: false
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.integer  "athena_id",             default: 0, null: false
    t.datetime "sync_updated_at"
    t.datetime "start_datetime",                    null: false
    t.integer  "appointment_type_id",               null: false
    t.string   "notes"
    t.datetime "deleted_at"
    t.integer  "booked_by_id",                      null: false
    t.integer  "provider_id",                       null: false
    t.integer  "patient_id",                        null: false
    t.integer  "appointment_status_id",             null: false
    t.integer  "rescheduled_id"
  end

  add_index "appointments", ["appointment_status_id"], name: "index_appointments_on_appointment_status_id", using: :btree
  add_index "appointments", ["appointment_type_id"], name: "index_appointments_on_appointment_type_id", using: :btree
  add_index "appointments", ["athena_id"], name: "index_appointments_on_athena_id", using: :btree
  add_index "appointments", ["booked_by_id"], name: "index_appointments_on_booked_by_id", using: :btree
  add_index "appointments", ["deleted_at"], name: "index_appointments_on_deleted_at", using: :btree
  add_index "appointments", ["patient_id"], name: "index_appointments_on_patient_id", using: :btree
  add_index "appointments", ["provider_id"], name: "index_appointments_on_provider_id", using: :btree
  add_index "appointments", ["start_datetime"], name: "index_appointments_on_start_datetime", using: :btree

  create_table "conversation_changes", force: :cascade do |t|
    t.integer  "conversation_id",     null: false
    t.string   "conversation_change"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  add_index "conversation_changes", ["conversation_id"], name: "index_conversation_changes_on_conversation_id", using: :btree

  create_table "conversations", force: :cascade do |t|
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "family_id"
    t.datetime "last_message_created_at"
    t.datetime "deleted_at"
    t.string   "status",                  null: false
    t.datetime "last_closed_at"
    t.integer  "last_closed_by"
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
  add_index "delayed_jobs", ["queue"], name: "index_delayed_jobs_on_queue", using: :btree

  create_table "enrollments", force: :cascade do |t|
    t.string   "title"
    t.string   "first_name"
    t.string   "middle_initial"
    t.string   "last_name"
    t.string   "suffix"
    t.string   "sex"
    t.integer  "practice_id"
    t.string   "email"
    t.string   "encrypted_password"
    t.integer  "family_id"
    t.string   "stripe_customer_id"
    t.integer  "role_id"
    t.datetime "deleted_at"
    t.date     "birth_date"
    t.string   "avatar_url"
    t.integer  "onboarding_group_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  create_table "families", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "insurance_plans", force: :cascade do |t|
    t.integer  "insurer_id", null: false
    t.string   "plan_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "insurance_plans", ["insurer_id"], name: "index_insurance_plans_on_insurer_id", using: :btree

  create_table "insurances", force: :cascade do |t|
    t.integer  "athena_id",          default: 0, null: false
    t.string   "plan_name"
    t.string   "plan_phone"
    t.string   "plan_type"
    t.string   "policy_number"
    t.string   "holder_ssn"
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
    t.date     "holder_birth_date"
  end

  add_index "insurances", ["athena_id"], name: "index_insurances_on_athena_id", using: :btree
  add_index "insurances", ["patient_id"], name: "index_insurances_on_patient_id", using: :btree

  create_table "insurers", force: :cascade do |t|
    t.string   "insurer_name", null: false
    t.string   "phone"
    t.string   "fax"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

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
    t.string   "type_name"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "escalated_to_id"
    t.datetime "escalated_at"
    t.integer  "escalated_by_id"
    t.datetime "deleted_at"
  end

  create_table "patients", force: :cascade do |t|
    t.string   "title"
    t.string   "first_name",                         null: false
    t.string   "middle_initial"
    t.string   "last_name",                          null: false
    t.string   "suffix"
    t.string   "sex",                                null: false
    t.integer  "family_id",                          null: false
    t.string   "email"
    t.string   "avatar_url"
    t.integer  "role_id",                default: 6, null: false
    t.datetime "deleted_at"
    t.date     "birth_date",                         null: false
    t.integer  "athena_id",              default: 0, null: false
    t.datetime "patient_updated_at"
    t.datetime "medications_updated_at"
    t.datetime "vaccines_updated_at"
    t.datetime "allergies_updated_at"
    t.datetime "vitals_updated_at"
    t.datetime "insurances_updated_at"
    t.datetime "photos_updated_at"
  end

  add_index "patients", ["athena_id"], name: "index_patients_on_athena_id", using: :btree
  add_index "patients", ["deleted_at"], name: "index_patients_on_deleted_at", using: :btree
  add_index "patients", ["first_name", "family_id"], name: "index_patients_on_first_name_and_family_id", using: :btree
  add_index "patients", ["first_name", "last_name"], name: "index_patients_on_first_name_and_last_name", using: :btree

  create_table "photos", force: :cascade do |t|
    t.integer  "patient_id"
    t.text     "image"
    t.datetime "taken_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "photos", ["patient_id"], name: "index_photos_on_patient_id", using: :btree

  create_table "practices", force: :cascade do |t|
    t.string   "name",           null: false
    t.string   "address_line_1"
    t.string   "address_line_2"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "fax"
    t.string   "phone"
    t.string   "email"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "provider_additional_availabilities", force: :cascade do |t|
    t.integer  "athena_provider_id", default: 0, null: false
    t.string   "description"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.datetime "start_datetime",                 null: false
    t.datetime "end_datetime",                   null: false
  end

  add_index "provider_additional_availabilities", ["athena_provider_id"], name: "index_provider_additional_availabilities_on_athena_provider_id", using: :btree

  create_table "provider_leaves", force: :cascade do |t|
    t.integer  "athena_provider_id", default: 0, null: false
    t.string   "description"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.datetime "start_datetime",                 null: false
    t.datetime "end_datetime",                   null: false
  end

  add_index "provider_leaves", ["athena_provider_id"], name: "index_provider_leaves_on_athena_provider_id", using: :btree

  create_table "provider_profiles", force: :cascade do |t|
    t.integer  "provider_id",                      null: false
    t.string   "specialties",                                   array: true
    t.string   "credentials",                                   array: true
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.integer  "athena_id",            default: 0, null: false
    t.integer  "athena_department_id", default: 0, null: false
  end

  add_index "provider_profiles", ["provider_id"], name: "index_provider_profiles_on_provider_id", unique: true, using: :btree

  create_table "provider_schedules", force: :cascade do |t|
    t.integer  "athena_provider_id",   default: 0, null: false
    t.string   "description"
    t.boolean  "active"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.string   "monday_start_time",                null: false
    t.string   "monday_end_time",                  null: false
    t.string   "tuesday_start_time",               null: false
    t.string   "tuesday_end_time",                 null: false
    t.string   "wednesday_start_time",             null: false
    t.string   "wednesday_end_time",               null: false
    t.string   "thursday_start_time",              null: false
    t.string   "thursday_end_time",                null: false
    t.string   "friday_start_time",                null: false
    t.string   "friday_end_time",                  null: false
    t.string   "saturday_start_time",              null: false
    t.string   "saturday_end_time",                null: false
    t.string   "sunday_start_time",                null: false
    t.string   "sunday_end_time",                  null: false
  end

  add_index "provider_schedules", ["athena_provider_id"], name: "index_provider_schedules_on_athena_provider_id", using: :btree

  create_table "read_receipts", force: :cascade do |t|
    t.integer  "message_id"
    t.string   "reader_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "read_receipts", ["message_id", "reader_id"], name: "index_read_receipts_on_message_id_and_reader_id", unique: true, using: :btree

  create_table "roles", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["name"], name: "index_roles_on_name", using: :btree

  create_table "sessions", force: :cascade do |t|
    t.integer  "user_id",              null: false
    t.string   "authentication_token", null: false
    t.datetime "deleted_at"
    t.string   "os_version"
    t.string   "platform"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "sessions", ["authentication_token"], name: "index_sessions_on_authentication_token", where: "(deleted_at IS NULL)", using: :btree
  add_index "sessions", ["deleted_at"], name: "index_sessions_on_deleted_at", using: :btree
  add_index "sessions", ["user_id"], name: "index_sessions_on_user_id", where: "(deleted_at IS NULL)", using: :btree

  create_table "sync_tasks", force: :cascade do |t|
    t.integer  "sync_id",     default: 0,  null: false
    t.string   "sync_type",   default: "", null: false
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.string   "sync_params", default: "", null: false
  end

  add_index "sync_tasks", ["sync_id"], name: "index_sync_tasks_on_sync_id", using: :btree
  add_index "sync_tasks", ["sync_type"], name: "index_sync_tasks_on_sync_type", using: :btree

  create_table "user_conversations", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "conversation_id"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.boolean  "read",            default: false, null: false
    t.boolean  "escalated",       default: false, null: false
    t.integer  "priority",        default: 0
  end

  add_index "user_conversations", ["conversation_id"], name: "index_user_conversations_on_conversation_id", using: :btree
  add_index "user_conversations", ["user_id"], name: "index_user_conversations_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "title"
    t.string   "first_name",                         null: false
    t.string   "middle_initial"
    t.string   "last_name",                          null: false
    t.string   "sex"
    t.integer  "practice_id"
    t.string   "email",                              null: false
    t.string   "encrypted_password"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
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
    t.integer  "family_id"
    t.string   "stripe_customer_id"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "suffix"
    t.integer  "role_id",                            null: false
    t.datetime "deleted_at"
    t.date     "birth_date"
    t.string   "avatar_url"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["deleted_at"], name: "index_users_on_deleted_at", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["first_name", "last_name"], name: "index_users_on_first_name_and_last_name", using: :btree
  add_index "users", ["invitation_token"], name: "index_users_on_invitation_token", unique: true, using: :btree
  add_index "users", ["invitations_count"], name: "index_users_on_invitations_count", using: :btree
  add_index "users", ["invited_by_id"], name: "index_users_on_invited_by_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["role_id"], name: "index_users_on_role_id", using: :btree

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
