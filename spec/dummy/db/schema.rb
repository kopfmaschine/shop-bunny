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

ActiveRecord::Schema.define(:version => 20120315160102) do

  create_table "cart_items", :force => true do |t|
    t.integer  "cart_id"
    t.integer  "quantity",   :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "raw_item"
  end

  create_table "carts", :force => true do |t|
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "coupon_uses", :force => true do |t|
    t.integer  "cart_id"
    t.integer  "coupon_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "coupon_uses", ["cart_id", "coupon_id"], :name => "index_coupon_uses_on_cart_id_and_coupon_id", :unique => true

  create_table "coupons", :force => true do |t|
    t.boolean  "removes_tax",            :default => false
    t.float    "discount_percentage",    :default => 1.0
    t.float    "discount_credit",        :default => 0.0
    t.boolean  "removes_shipping_cost",  :default => false
    t.integer  "bonus_article_id"
    t.datetime "valid_from"
    t.datetime "valid_until"
    t.text     "title"
    t.string   "code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "value_of_automatic_add"
    t.integer  "max_uses"
    t.string   "state"
    t.float    "minimum_order_value"
  end

  create_table "items", :force => true do |t|
    t.float    "price"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
