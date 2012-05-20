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

ActiveRecord::Schema.define(:version => 20120519074733) do

  create_table "accounts", :force => true do |t|
    t.string   "email",              :limit => 150,                      :null => false
    t.string   "role",               :limit => 50,  :default => "admin", :null => false
    t.string   "encrypted_password"
    t.string   "password_salt"
    t.string   "perishable_token"
    t.datetime "confirmed_at"
    t.integer  "project_id"
    t.integer  "tenant_id"
    t.integer  "person_id"
    t.datetime "created_at",                                             :null => false
    t.datetime "updated_at",                                             :null => false
    t.datetime "reset_at"
    t.string   "type",               :limit => 20
  end

  add_index "accounts", ["type"], :name => "index_accounts_on_type"

  create_table "contributors", :force => true do |t|
    t.string   "type"
    t.integer  "project_id"
    t.integer  "tenant_id"
    t.integer  "person_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "conversations", :force => true do |t|
    t.datetime "start_at"
    t.datetime "end_at"
    t.integer  "tenant_id",   :null => false
    t.integer  "location_id", :null => false
  end

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
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
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
