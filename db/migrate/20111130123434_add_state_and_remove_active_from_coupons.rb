class AddStateAndRemoveActiveFromCoupons < ActiveRecord::Migration
  def self.up
    add_column :coupons, :state, :string
    remove_column :coupons, :active
  end

  def self.down
    remove_column :coupons, :state
    add_column :coupons, :active, :boolean
  end
end