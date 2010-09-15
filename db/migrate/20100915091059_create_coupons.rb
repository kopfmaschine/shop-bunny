class CreateCoupons < ActiveRecord::Migration
  def self.up
    create_table :coupons do |t|
      t.boolean :removes_tax, :default => false
      t.float :discount_percentage, :default => 1.0
      t.float :discount_credit, :default => 0.0
      t.boolean :removes_shipping_cost, :default => false
      t.integer :bonus_article_id
      t.date :valid_from
      t.date :valid_until
      t.text :title
      t.string :code

      t.timestamps
    end
  end

  def self.down
    drop_table :coupons
  end
end
