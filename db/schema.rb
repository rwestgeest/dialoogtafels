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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121026062625) do

  create_table "accounts", :force => true do |t|
    t.string   "email",                :limit => 150,                      :null => false
    t.string   "role",                 :limit => 50,  :default => "admin", :null => false
    t.string   "encrypted_password"
    t.string   "password_salt"
    t.string   "authentication_token"
    t.datetime "confirmed_at"
    t.integer  "project_id"
    t.integer  "tenant_id"
    t.integer  "person_id"
    t.datetime "created_at",                                               :null => false
    t.datetime "updated_at",                                               :null => false
    t.datetime "reset_at"
    t.string   "type",                 :limit => 20
  end

  add_index "accounts", ["type"], :name => "index_accounts_on_type"

  create_table "contributors", :force => true do |t|
    t.string   "type"
    t.integer  "project_id"
    t.integer  "tenant_id"
    t.integer  "person_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "conversation_id"
  end

  add_index "contributors", ["conversation_id"], :name => "index_contributors_on_conversation_id"
  add_index "contributors", ["project_id"], :name => "index_contributors_on_project_id"

  create_table "conversations", :force => true do |t|
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer  "number_of_tables",          :default => 1
    t.integer  "tenant_id",                                :null => false
    t.integer  "location_id",                              :null => false
    t.integer  "participant_count",         :default => 0
    t.integer  "conversation_leader_count", :default => 0
  end

  add_index "conversations", ["location_id"], :name => "index_conversations_on_location_id"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "finished_location_todos", :force => true do |t|
    t.integer  "location_todo_id"
    t.integer  "location_id"
    t.integer  "tenant_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "finished_location_todos", ["location_id"], :name => "index_finished_location_todos_on_location_id"
  add_index "finished_location_todos", ["location_todo_id"], :name => "index_finished_location_todos_on_location_todo_id"

  create_table "location_todos", :force => true do |t|
    t.string   "name",       :limit => 100
    t.integer  "project_id"
    t.integer  "tenant_id"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "location_todos", ["name"], :name => "index_location_todos_on_name"
  add_index "location_todos", ["project_id"], :name => "index_location_todos_on_project_id"

  create_table "locations", :force => true do |t|
    t.string   "name",               :limit => 100
    t.string   "postal_code",        :limit => 10,                     :null => false
    t.string   "address",            :limit => 100,                    :null => false
    t.string   "city",               :limit => 100,                    :null => false
    t.float    "lattitude"
    t.float    "longitude"
    t.integer  "project_id",                                           :null => false
    t.integer  "tenant_id",                                            :null => false
    t.integer  "organizer_id",                                         :null => false
    t.datetime "created_at",                                           :null => false
    t.datetime "updated_at",                                           :null => false
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.boolean  "published",                         :default => false
    t.text     "description"
  end

  create_table "message_addressees", :force => true do |t|
    t.integer  "message_id"
    t.integer  "person_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "message_addressees", ["message_id"], :name => "index_comment_addressees_on_location_comment_id"
  add_index "message_addressees", ["person_id"], :name => "index_comment_addressees_on_person_id"

  create_table "messages", :force => true do |t|
    t.text     "body"
    t.string   "ancestry"
    t.integer  "author_id"
    t.integer  "reference_id"
    t.integer  "tenant_id"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.string   "subject"
    t.string   "type"
    t.string   "addressee_groups", :default => ""
  end

  add_index "messages", ["ancestry"], :name => "index_location_comments_on_ancestry"
  add_index "messages", ["author_id"], :name => "index_location_comments_on_author_id"
  add_index "messages", ["tenant_id"], :name => "index_location_comments_on_tenant_id"
  add_index "messages", ["type"], :name => "index_messages_on_type"

  create_table "people", :force => true do |t|
    t.string   "name",       :limit => 50, :null => false
    t.string   "telephone",  :limit => 50, :null => false
    t.integer  "project_id"
    t.integer  "tenant_id"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  create_table "profile_field_values", :force => true do |t|
    t.integer "person_id"
    t.integer "profile_field_id"
    t.string  "value"
    t.integer "tenant_id"
  end

  add_index "profile_field_values", ["tenant_id", "person_id"], :name => "index_profile_field_values_on_tenant_id_and_person_id"
  add_index "profile_field_values", ["tenant_id", "profile_field_id"], :name => "index_profile_field_values_on_tenant_id_and_profile_field_id"

  create_table "profile_fields", :force => true do |t|
    t.string   "label",      :limit => 50,   :default => ""
    t.string   "type",       :limit => 1000
    t.text     "values",                     :default => ""
    t.integer  "order",                      :default => 0
    t.integer  "tenant_id"
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
    t.string   "field_name", :limit => 50,   :default => ""
    t.boolean  "on_form",                    :default => false
  end

  add_index "profile_fields", ["field_name"], :name => "index_profile_fields_on_field_name"
  add_index "profile_fields", ["on_form"], :name => "index_profile_fields_on_on_form"
  add_index "profile_fields", ["tenant_id", "order"], :name => "index_profile_fields_on_tenant_id_and_order"

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.integer  "tenant_id"
    t.datetime "created_at",                                                                                                                                    :null => false
    t.datetime "updated_at",                                                                                                                                    :null => false
    t.integer  "conversation_length",                      :default => 180
    t.datetime "start_time"
    t.integer  "max_participants_per_table",               :default => 8
    t.boolean  "trainings_on_form",                        :default => true
    t.text     "organizer_confirmation_text",              :default => "'Welkom,\n\nDankje voor je aanmelding als tafelorganistor aan de dag van de dialoog.'"
    t.text     "participant_confirmation_text",            :default => "'Welkom,\n\nDankje voor je aanmelding als deelnemer aan de dag van de dialoog.'"
    t.text     "conversation_leader_confirmation_text",    :default => "'Welkom,\n\nDankje voor je aanmelding als gespreksleider aan de dag van de dialoog.'"
    t.string   "grouping_strategy",                        :default => "none",                                                                                  :null => false
    t.string   "organizer_confirmation_subject",           :default => "Welkom bij dialoogtafels - er is een account voor je aangemaakt",                       :null => false
    t.string   "participant_confirmation_subject",         :default => "Welkom bij dialoogtafels",                                                              :null => false
    t.string   "conversation_leader_confirmation_subject", :default => "Welkom bij dialoogtafels",                                                              :null => false
    t.boolean  "obligatory_training_registration",         :default => false
    t.string   "cc_address_list"
    t.string   "cc_type",                                  :default => "none",                                                                                  :null => false
  end

  create_table "tenants", :force => true do |t|
    t.string   "name",                     :limit => 50,                                                       :null => false
    t.string   "url_code",                 :limit => 50,                                                       :null => false
    t.string   "representative_name",      :limit => 50,                                                       :null => false
    t.string   "representative_email",     :limit => 150,                                                      :null => false
    t.string   "representative_telephone", :limit => 50,                                                       :null => false
    t.text     "invoice_address"
    t.string   "site_url",                 :limit => 250,                                                      :null => false
    t.string   "info_email",               :limit => 150,                                                      :null => false
    t.string   "from_email",               :limit => 150,                                                      :null => false
    t.datetime "created_at",                                                                                   :null => false
    t.datetime "updated_at",                                                                                   :null => false
    t.integer  "current_project_id"
    t.integer  "active_project_id"
    t.string   "host",                     :limit => 250, :default => "",                                      :null => false
    t.string   "top_image",                               :default => "/assets/default_header_background.png"
    t.string   "right_image",                             :default => "/assets/deault_city_name_right.png"
    t.string   "public_style_sheet",                      :default => "public"
    t.boolean  "framed_integration",                      :default => false
  end

  add_index "tenants", ["current_project_id"], :name => "index_tenants_on_current_project_id"
  add_index "tenants", ["host"], :name => "index_tenants_on_host"
  add_index "tenants", ["url_code"], :name => "index_tenants_on_url_code"

  create_table "training_registrations", :force => true do |t|
    t.integer  "attendee_id"
    t.integer  "training_id"
    t.boolean  "invited",     :default => false
    t.integer  "tenant_id"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  add_index "training_registrations", ["tenant_id"], :name => "index_training_registrations_on_tenant_id"
  add_index "training_registrations", ["training_id", "attendee_id"], :name => "index_training_registrations_on_training_id_and_attendee_id"

  create_table "training_types", :force => true do |t|
    t.string   "name",        :default => "", :null => false
    t.text     "description", :default => ""
    t.integer  "project_id"
    t.integer  "tenant_id"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
  end

  add_index "training_types", ["project_id"], :name => "index_training_types_on_project_id"
  add_index "training_types", ["tenant_id"], :name => "index_training_types_on_tenant_id"

  create_table "trainings", :force => true do |t|
    t.datetime "start_time",                        :null => false
    t.datetime "end_time",                          :null => false
    t.integer  "max_participants",  :default => 20
    t.string   "location",          :default => "", :null => false
    t.integer  "participant_count", :default => 0
    t.integer  "tenant_id"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.integer  "training_type_id"
  end

  add_index "trainings", ["location", "start_time"], :name => "index_trainings_on_location_and_start_time"
  add_index "trainings", ["tenant_id"], :name => "index_trainings_on_tenant_id"
  add_index "trainings", ["tenant_id"], :name => "index_trainings_on_tenant_id_and_project_id"
  add_index "trainings", ["training_type_id"], :name => "index_trainings_on_training_type_id"

end
