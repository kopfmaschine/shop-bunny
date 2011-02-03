class CartItem < ActiveRecord::Base
  belongs_to :cart
  # belongs_to :item, :class_name => ShopBunny.item_model_class_name
  
  validates_presence_of :cart_id
  # validates_presence_of :item_id
  validates_numericality_of :quantity
  
  before_validation :set_default_quantity
  after_update :destroy_if_empty
  
  after_save :touch_cart
  after_destroy :touch_cart
  
  # TODO attr_accessible :quantity
  
  def total_price
    quantity * item.price
  end
  
  def item=(new_item)
    write_attribute(:raw_item, new_item.to_json)
    @parsed_raw_item = nil
    new_item
  end
  
  def item
    return nil unless raw_item
    unless @parsed_raw_item
      json = JSON.parse(raw_item).values.first
      if json
        @parsed_raw_item = ShopBunny.item_model_class_name.constantize.new(json)
        @parsed_raw_item.id = json['id']
      end
    end
    @parsed_raw_item
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
  
  protected
  def touch_cart
    cart.touch if cart
  end
end
