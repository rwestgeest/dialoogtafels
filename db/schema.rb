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

ActiveRecord::Schema.define(:version => 20120507082629) do

  create_table "account", :force => true do |t|
    t.string   "email",              :limit => 150,                :null => false
    t.string   "role",               :limit => 50,                 :null => false
    t.string   "crypted_password",                                 :null => false
    t.string   "password_salt",                                    :null => false
    t.string   "persistence_token",                                :null => false
    t.string   "perishable_token",                                 :null => false
    t.integer  "login_count",                       :default => 0, :null => false
    t.integer  "failed_login_count",                :default => 0, :null => false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
    t.integer  "project_id"
    t.integer  "tenant_id"
    t.integer  "person_id"
    t.datetime "created_at",                                       :null => false
    t.datetime "updated_at",                                       :null => false
  end

  create_table "contributors", :force => true do |t|
    t.string   "type"
    t.integer  "project_id"
    t.integer  "tenant_id"
    t.integer  "person_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
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
  end

  add_index "tenants", ["current_project_id"], :name => "index_tenants_on_current_project_id"
  add_index "tenants", ["url_code"], :name => "index_tenants_on_url_code"

end
