class RemoveOwnerIdFromCarts < ActiveRecord::Migration
  def self.up
    remove_column :carts, :owner_id
  end

  def self.down
    add_column :carts, :owner_id, :integer
  end
end
