module ShopBunny
  module CartModule
  
    def self.included(clazz)
      clazz.send(:attr_accessor, :coupon_code)
      clazz.send(:has_many, :cart_items, :dependent => :destroy, :class_name => 'ShopBunny::CartItem')
      clazz.send(:has_many, :coupon_uses, :dependent => :destroy, :class_name => 'ShopBunny::CouponUse')
      clazz.send(:has_many, :coupons, :through => :coupon_uses)
      clazz.send(:accepts_nested_attributes_for, :cart_items, :allow_destroy => true )
      clazz.send(:before_save, :update_coupons)
      clazz.send(:after_save, :free_coupon_code)
      clazz.send(:attr_accessible, :coupon_code, :cart_items_attributes)
      clazz.send(:validate, :coupon_code_must_be_valid)
    end
  
    def items
      self.cart_items
    end

    def bonus_items
      coupons.map(&:bonus_article).compact
    end

    def item_count
      self.cart_items.inject(0) {|sum,e| sum += e.quantity}
    end

    def shipping_costs(options = {})
      return 0 if coupons.any?(&:removes_shipping_cost)
      shipping_cost_calculator.costs_for(self, options)
    end

    # Calculates the sum of all cart_items, excluding the coupons discount!
    def item_sum
      begin
        self.cart_items.inject(0) do |sum,e|
          sum += e.quantity*e.item.price unless e.item.nil?
        end
      rescue Exception => err
        logger.warn "item_sum could not be calculated: #{err}"
        "error: item not processible"
      end
    end

    def items_with_coupons
      sum = item_sum

      absolute_discount = coupons.sum(:discount_credit)
      relative_discount = coupons.inject(1) {|s,coupon| s * coupon.discount_percentage }

      sum -= absolute_discount
      sum *= relative_discount
    end

    # Calculates the total sum and applies the coupons discount! 
    def total
      [0, items_with_coupons + shipping_costs].max
    end
    
    # Adds one or options[:quantity] number of items to the cart or increases it's quantity.
    def add_item(item,options = {})
      cart_item = find_cart_item(item)
      cart_item ||= self.cart_items.build(:item => item)
      cart_item.quantity += options[:quantity] || 1
      cart_item.save!
      self.reload
    end
    
    # Decreases the quantity of an item in the cart by 1 or options[:quantity]
    def remove_item(item,options = {})
      cart_item = find_cart_item(item)
      if cart_item
        options[:quantity] ||= cart_item.quantity
        if cart_item
          cart_item.quantity -= options[:quantity]
          cart_item.save!
          self.reload
        end
      end
    end

    # Sets the quantity of the item to options[:quantity]
    def update_item(item,options)
      cart_item = find_cart_item(item)
      if cart_item
        cart_item.quantity = options[:quantity]
        cart_item.save!
        self.reload
      end
    end

    def shipping_cost_calculator
      ShopBunny.shipping_cost_calculator
    end
    
    # Returns the class/model of the items you can buy. (Products)
    def item_model
      ShopBunny.item_model_class_name.constantize
    end
    
    # Check if the cart is empty
    def empty?
      cart_items.empty? && bonus_items.empty?
    end
    
    # Remove all items and coupons from the cart
    def clear!
      cart_items.clear
      coupons.clear
    end
    
    def as_json(options={})
      { 
        :cart => attributes.
        merge(
          :cart_items => cart_items.as_json,
          :item_count => item_count || 0,
          :coupons => coupons.as_json,
          :item_sum => item_sum,
          :shipping_costs => shipping_costs,
          :total => total,
          :items_with_coupons => items_with_coupons
        )
      }
    end

    def update_automatic_coupons!
      coupon_uses.joins(:coupon).where('coupons.value_of_automatic_add IS NOT NULL').destroy_all
      Coupon.valid.automatically_added_over(item_sum).each do |coupon|
        coupons << coupon
      end
    end

    protected
    def find_cart_item(item)
      self.cart_items.detect {|e| e.item.id == item.id}
    end

    def update_coupons
      Array(@coupon_code).each { |code|
        coupon = Coupon.find_by_code(code)
        return if coupons.include? coupon
        coupons << coupon if coupon && coupon.redeemable?
      }
    end

    def free_coupon_code
      self.coupon_code = nil
    end
    
    def coupon_code_must_be_valid
      Array(@coupon_code).each { |code|
        coupon = Coupon.find_by_code(code)
        if coupon.nil?
          errors.add(:coupon_code, :unknown)
        elsif coupon.expired?
          errors.add(:coupon_code, :expired)
        elsif coupon.used_up? && !coupons.include?(coupon)
          errors.add(:coupon_code, :used_up)
        elsif !coupon.redeemable?
          errors.add(:coupon_code, :not_redeemable)
        elsif coupons.map(&:code).include? coupon.code
          errors.add(:coupon_code, :already_added)
        end
      }
    end
  end
end
