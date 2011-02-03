class AddRawItemToCartItems < ActiveRecord::Migration
  def self.up
    add_column :cart_items, :raw_item, :text
    
    CartItem.all.each do |e|
      if e.read_attribute(:item_id)
        i = ShopBunny.item_model_class_name.constantize.find_by_id(e.read_attribute(:item_id))
        if i
          e.raw_item = i.to_json
          e.save!
        end
      end
    end
  end

  def self.down
    remove_column :cart_items, :raw_item
  end
end
