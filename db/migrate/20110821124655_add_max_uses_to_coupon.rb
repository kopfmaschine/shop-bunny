class AddMaxUsesToCoupon < ActiveRecord::Migration
  def self.up
    add_column :coupons, :max_uses, :integer
  end

  def self.down
    remove_column :coupons, :max_uses
  end
end
