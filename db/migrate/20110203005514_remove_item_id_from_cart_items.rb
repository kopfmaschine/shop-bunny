class RemoveItemIdFromCartItems < ActiveRecord::Migration
  def self.up
    remove_column :cart_items, :item_id
  end

  def self.down
    add_column :cart_items, :item_id, :integer
  end
end
