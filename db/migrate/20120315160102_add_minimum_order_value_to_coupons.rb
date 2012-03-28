class AddMinimumOrderValueToCoupons < ActiveRecord::Migration
  def change
    add_column :coupons, :minimum_order_value, :float

  end
end
