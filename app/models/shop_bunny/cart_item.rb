class ShopBunny::CartItem < ActiveRecord::Base
  belongs_to :cart
  # belongs_to :item, :class_name => ShopBunny.item_model_class_name
  
  validates_presence_of :cart_id
  # validates_presence_of :item_id
  validates_numericality_of :quantity
  
  before_validation :set_default_quantity
  after_update :destroy_if_empty
  
  # TODO attr_accessible :quantity
  
  def total_price
    quantity * item.price
  end
  
  def item=(new_item)
    write_attribute(:raw_item, (new_item.respond_to?(:shop_bunny_json_attributes) ? new_item.shop_bunny_json_attributes : new_item.attributes).to_json)
    @parsed_raw_item = nil
    new_item
  end
  
  def item
    return nil unless raw_item
    unless @parsed_raw_item
      json = JSON.parse(raw_item)
        
      if json
        @parsed_raw_item = ShopBunny.item_model_class_name.constantize.new(json)
        @parsed_raw_item.id = json['id']
      end
    end
    @parsed_raw_item
  end

  def as_json(options={})
    {
      :quantity => quantity,
      :id => item.id
    }
  end

  private
  
  def set_default_quantity
    self.quantity ||= 0
  end
  
  def destroy_if_empty
    self.destroy if quantity.to_i <= 0
  end
  
  def self.include_enhancements
    ShopBunny.cart_item_enhancements.each do |enhancement|
      include enhancement
    end
  end
  
  ShopBunny.cart_item_enhancements.each do |enhancement|
    include enhancement
  end
end
