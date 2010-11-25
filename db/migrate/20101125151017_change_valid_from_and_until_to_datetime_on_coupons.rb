class ChangeValidFromAndUntilToDatetimeOnCoupons < ActiveRecord::Migration
  def self.up
    change_column :coupons, :valid_from, :datetime
    change_column :coupons, :valid_until, :datetime
  end

  def self.down
    change_column :coupons, :valid_until, :date
    change_column :coupons, :valid_from, :date
  end
end