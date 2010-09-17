class SetDefaultColumnValueForCartItemsQuantity < ActiveRecord::Migration
  def self.up
    change_column_default :cart_items, :quantity, 0
  end

  def self.down
    change_column_default :cart_items, :quantity, nil
  end
end