class AddRawItemToCartItems < ActiveRecord::Migration
  def self.up
    add_column :cart_items, :raw_item, :text
    
    CartItem.all.each do |e|
      if e.item
        e.raw_item = e.item.to_json
        e.save!
      end
    end
  end

  def self.down
    remove_column :cart_items, :raw_item
  end
end
