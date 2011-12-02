module ShopBunny
  module CartModule
  
    def self.included(clazz)
      clazz.send(:attr_accessor, :coupon_code)
      clazz.send(:has_many, :cart_items, :dependent => :destroy, :class_name => 'ShopBunny::CartItem')
      clazz.send(:has_many, :coupon_uses, :dependent => :destroy, :class_name => 'ShopBunny::CouponUse')
      clazz.send(:has_many, :coupons, :through => :coupon_uses)
      clazz.send(:accepts_nested_attributes_for, :cart_items, :allow_destroy => true )
      clazz.send(:before_save, :update_coupons)
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
    
    #increases the quantity of an article. creates a new one if it doesn't exist
    def add_item(item,options = {})
      options[:quantity] ||= 1
      cart_item = self.cart_items.select {|e| e.item.id == item.id}.first 
      cart_item ||= self.cart_items.build
      cart_item.item = item
      cart_item.quantity += options[:quantity]
      cart_item.save!
      
      update_automatic_coupons!
      
      self.save!
      self.reload
      cart_item
    end
    
    #removes a quantity of an article specified by :article_id, returns nil if no article has been found
    def remove_item(item,options = {})
      cart_item = self.cart_items.select {|e| e.item.id == item.id}.first
      if cart_item
        options[:quantity] ||= cart_item.quantity
        if cart_item
          cart_item.quantity -= options[:quantity]
          cart_item.save!
          self.reload
        end
      end
      
      update_automatic_coupons!
      
      cart_item
    end

    #sets the quantity of an article specified by :article_id, returns nil if no article has been found
    def update_item(item,options)
      cart_item = self.cart_items.select {|e| e.item.id == item.id}.first
      if cart_item
        cart_item.quantity = options[:quantity]
        cart_item.save!
        self.reload
      end

      update_automatic_coupons!

      cart_item
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
    
    # Remove all items from the cart
    def clear!
      cart_items.each {|i| i.destroy}
      cart_items.clear
      
      coupon_uses.each {|u| u.destroy}
      coupon_uses.clear
      coupons.clear
    end
    
    # Make
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
      coupon_uses.each do |use|
        use.destroy if use.coupon.value_of_automatic_add
      end

      save
      reload

      Coupon.valid.automatically_added_over(item_sum).each do |coupon|
        coupons << coupon
      end
    end

    protected
    def update_coupons
      Array(@coupon_code).each { |code|
        coupon = Coupon.find_by_code(code)
        coupons << coupon if coupon && !coupons.include?(coupon) && coupon.redeemable?
      }
    end
    
    def coupon_code_must_be_valid
      Array(@coupon_code).each { |code|
        coupon = Coupon.find_by_code(code)
        if coupon.nil?
          errors.add(:coupon_code, :unknown)
        elsif coupon.expired?
          errors.add(:coupon_code, :expired)
        elsif coupon.used_up?
          errors.add(:coupon_code, :used_up)
        end
      }
    end
  end
end
