class AddActiveFlagToCoupon < ActiveRecord::Migration
  def self.up
    add_column :coupons, :active, :boolean
  end

  def self.down
    remove_column :coupons, :active
  end
end
