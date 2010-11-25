class AddValueOfAutomaticAddToCoupons < ActiveRecord::Migration
  def self.up
    add_column :coupons, :value_of_automatic_add, :float
  end

  def self.down
    remove_column :coupons, :value_of_automatic_add
  end
end
