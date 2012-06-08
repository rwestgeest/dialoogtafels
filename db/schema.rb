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

ActiveRecord::Schema.define(:version => 20120608144452) do

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
    t.integer  "number_of_tables", :default => 1
    t.integer  "tenant_id",                       :null => false
    t.integer  "location_id",                     :null => false
  end

  add_index "conversations", ["location_id"], :name => "index_conversations_on_location_id"

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
    t.string   "name",                     :limit => 50,  :null => false
    t.string   "url_code",                 :limit => 50,  :null => false
    t.string   "representative_name",      :limit => 50,  :null => false
    t.string   "representative_email",     :limit => 150, :null => false
    t.string   "representative_telephone", :limit => 50,  :null => false
    t.text     "invoice_address"
    t.string   "site_url",                 :limit => 250, :null => false
    t.string   "info_email",               :limit => 150, :null => false
    t.string   "from_email",               :limit => 150, :null => false
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
    t.integer  "current_project_id"
    t.integer  "active_project_id"
  end

  add_index "tenants", ["current_project_id"], :name => "index_tenants_on_current_project_id"
  add_index "tenants", ["url_code"], :name => "index_tenants_on_url_code"

end
