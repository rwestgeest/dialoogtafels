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

ActiveRecord::Schema.define(:version => 20120625091103) do

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

  create_table "comment_addressees", :force => true do |t|
    t.integer  "location_comment_id"
    t.integer  "person_id"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  add_index "comment_addressees", ["location_comment_id"], :name => "index_comment_addressees_on_location_comment_id"
  add_index "comment_addressees", ["person_id"], :name => "index_comment_addressees_on_person_id"

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
    t.integer  "number_of_tables", :default => 1
    t.integer  "tenant_id",                       :null => false
    t.integer  "location_id",                     :null => false
  end

  add_index "conversations", ["location_id"], :name => "index_conversations_on_location_id"

  create_table "location_comments", :force => true do |t|
    t.text     "body"
    t.string   "ancestry"
    t.integer  "author_id"
    t.integer  "location_id"
    t.integer  "tenant_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "subject"
  end

  add_index "location_comments", ["ancestry"], :name => "index_location_comments_on_ancestry"
  add_index "location_comments", ["author_id"], :name => "index_location_comments_on_author_id"
  add_index "location_comments", ["tenant_id"], :name => "index_location_comments_on_tenant_id"

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
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
    t.string   "field_name", :limit => 50,   :default => ""
  end

  add_index "profile_fields", ["field_name"], :name => "index_profile_fields_on_field_name"
  add_index "profile_fields", ["tenant_id", "order"], :name => "index_profile_fields_on_tenant_id_and_order"

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.integer  "tenant_id"
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
    t.integer  "conversation_length",        :default => 180
    t.datetime "start_time"
    t.integer  "max_participants_per_table", :default => 8
  end

  create_table "tenants", :force => true do |t|
    t.string   "name",                     :limit => 50,                  :null => false
    t.string   "url_code",                 :limit => 50,                  :null => false
    t.string   "representative_name",      :limit => 50,                  :null => false
    t.string   "representative_email",     :limit => 150,                 :null => false
    t.string   "representative_telephone", :limit => 50,                  :null => false
    t.text     "invoice_address"
    t.string   "site_url",                 :limit => 250,                 :null => false
    t.string   "info_email",               :limit => 150,                 :null => false
    t.string   "from_email",               :limit => 150,                 :null => false
    t.datetime "created_at",                                              :null => false
    t.datetime "updated_at",                                              :null => false
    t.integer  "current_project_id"
    t.integer  "active_project_id"
    t.string   "host",                     :limit => 250, :default => "", :null => false
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

  create_table "trainings", :force => true do |t|
    t.datetime "start_time",                        :null => false
    t.datetime "end_time",                          :null => false
    t.integer  "max_participants",  :default => 20
    t.string   "name",              :default => "", :null => false
    t.text     "description",       :default => ""
    t.string   "location",          :default => "", :null => false
    t.integer  "participant_count", :default => 0
    t.integer  "tenant_id"
    t.integer  "project_id"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  add_index "trainings", ["location", "start_time"], :name => "index_trainings_on_location_and_start_time"
  add_index "trainings", ["tenant_id", "project_id"], :name => "index_trainings_on_tenant_id_and_project_id"
  add_index "trainings", ["tenant_id"], :name => "index_trainings_on_tenant_id"

end
