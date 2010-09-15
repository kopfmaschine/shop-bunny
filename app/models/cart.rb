    class Cart < ActiveRecord::Base
  has_many :cart_items
  
  validates_presence_of :owner_id
  
  def items
    self.cart_items
  end
  
  def item_count
    self.cart_items.inject(0) {|sum,e| sum += e.quantity}
  end

  def item_sum
    self.cart_items.inject(0) {|sum,e| sum += e.quantity*e.item.price}
  end

  #increases the quantity of an article. creates a new one if it doesn't exist
  def add_item(item,options = {})
    options[:quantity] ||= 1
    cart_item = self.cart_items.find_or_create_by_item_id(item.id)
    cart_item.quantity += options[:quantity]
    cart_item.save!
    self.reload
    cart_item
  end

#  def add_coupon(coupon)
#    coupon_item = self.coupon_items.find_or_create_by_coupon(coupon)
#    coupon_item.quantity += options[:quantity]
#    coupon_item.save!
#    self.reload
#    coupon_item
#  end


  
  #removes a quantity of an article specified by :article_id, returns nil if no article has been found
  def remove_item(item,options)
    cart_item = self.cart_items.find_by_item_id(item)
    if cart_item
      cart_item.quantity -= options[:quantity]
      cart_item.quantity = 0 if cart_item.quantity < 0
      cart_item.save!
      self.reload
    end
    cart_item
  end

  #sets the quantity of an article specified by :article_id, returns nil if no article has been found
  def update_item(item,options)
     cart_item = self.cart_items.find_by_item_id(item)
    if cart_item
      cart_item.quantity = options[:quantity]
      cart_item.save!
      self.reload
    end
    cart_item
  end
end
