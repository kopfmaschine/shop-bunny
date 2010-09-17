class Cart < ActiveRecord::Base
  attr_accessor :coupon_code
  has_many :cart_items, :dependent => :destroy
  has_many :coupon_uses, :dependent => :destroy
  has_many :coupons, :through => :coupon_uses
  accepts_nested_attributes_for :cart_items, :allow_destroy => true 
  before_save :update_coupons
  attr_accessible :coupon_code, :cart_items_attributes
  validate :coupon_code_must_be_valid    
  
  def items
    self.cart_items
  end
  
  def item_count
    self.cart_items.inject(0) {|sum,e| sum += e.quantity}
  end
  
  def shipping_costs
    return 0 if coupons.any?(&:removes_shipping_cost)
    shipping_cost_calculator.costs_for(self)
  end

  # Calculates the sum of all cart_items, excluding the coupons discount!
  def item_sum
    self.cart_items.inject(0) {|sum,e| sum += e.quantity*e.item.price}
  end

  # Calculates the total sum and applies the coupons discount! 
  def total
    sum = item_sum

    absolute_discount = coupons.sum(:discount_credit)
    relative_discount = coupons.inject(1) {|s,coupon| s * coupon.discount_percentage }

    sum -= absolute_discount
    sum *= relative_discount
    
    sum + shipping_costs
    sum 
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
  
  #removes a quantity of an article specified by :article_id, returns nil if no article has been found
  def remove_item(item,options = {})
    options[:quantity] ||= 1
    cart_item = self.cart_items.find_by_item_id(item)
    if cart_item
      cart_item.quantity -= options[:quantity]
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
  
  def shipping_cost_calculator
    ShopBunny.shipping_cost_calculator
  end
  
  # Returns the class/model of the items you can buy. (Products)
  def item_model
    ShopBunny.item_model_class_name.constantize
  end
  
  private
  
  def update_coupons
    Array(@coupon_code).each { |code|
      coupon = Coupon.find_by_code(code)
      coupons << coupon if coupon
    }
  end
  
  def coupon_code_must_be_valid
    Array(@coupon_code).each { |code|
      coupon = Coupon.find_by_code(code)
      if coupon.nil?
        errors.add(:coupon_code, "is unknown")
      elsif coupon.expired?
        errors.add(:coupon_code, "is expired")
      end
    }
  end
end
