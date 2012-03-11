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

ActiveRecord::Schema.define(:version => 7) do

  create_table "accounts", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.string   "name",       :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "labels", :force => true do |t|
    t.integer "user_id"
    t.string  "name",    :null => false
    t.boolean "system",  :null => false
  end

  create_table "labels_messages", :force => true do |t|
    t.integer "message_id", :null => false
    t.integer "label_id",   :null => false
  end

  add_index "labels_messages", ["label_id", "message_id"], :name => "index_labels_messages_on_label_id_and_message_id"
  add_index "labels_messages", ["label_id"], :name => "index_labels_messages_on_label_id"
  add_index "labels_messages", ["message_id"], :name => "index_labels_messages_on_message_id"

  create_table "messages", :force => true do |t|
    t.integer  "user_id",                           :null => false
    t.integer  "account_id",                        :null => false
    t.datetime "header_date"
    t.string   "header_message_id"
    t.string   "thread_id"
    t.string   "header_from"
    t.string   "header_to",         :limit => 1000
    t.string   "header_subject"
    t.boolean  "read",                              :null => false
    t.boolean  "has_attachments",                   :null => false
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  add_index "messages", ["header_date"], :name => "index_messages_on_header_date"
  add_index "messages", ["header_message_id"], :name => "index_messages_on_header_message_id"
  add_index "messages", ["header_subject"], :name => "index_messages_on_header_subject"
  add_index "messages", ["id"], :name => "index_messages_on_id"
  add_index "messages", ["thread_id"], :name => "index_messages_on_thread_id"

  create_table "tokens", :force => true do |t|
    t.integer  "user_id", :null => false
    t.string   "token",   :null => false
    t.datetime "expires", :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "username",        :null => false
    t.string   "password_digest", :null => false
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

end
