    require 'spec_helper'

describe Cart do
  it { should have_many :cart_items}
  
  context "A Cart" do
    before(:each) do
      @article1 = Item.make(:price => 10.0)
      @article2 = Item.make(:price => 20.0)
      @cart = Cart.make
    end    
    
    it "should be able to add articles" do
      proc {@cart.add_item(@article1, :quantity => 1)}.should change(@cart, :item_count).by(1)
      @cart.items.size.should be(1)
      @cart.item_sum.should be_close(10.0,0.01)
      proc {@cart.add_item(@article2, :quantity => 1)}.should change(@cart, :item_count).by(1)
      @cart.items.size.should be(2)
      @cart.item_sum.should be_close(30.0,0.01)
      proc {@cart.add_item(@article1, :quantity => 3)}.should change(@cart, :item_count).by(3)
      @cart.items.size.should be(2)
      @cart.item_sum.should be_close(60.0,0.01)
    end    
    
    it "should be able to set a default quantity with 1" do
      proc {@cart.add_item(@article1)}.should change(@cart, :item_count).by(1)      
    end
       
    it "passes shipping_cost requests to the shipping costs calculator" do
      calculator = mock()
      calculator.expects(:costs_for).with(@cart, anything).once
      
      @cart.stubs(:shipping_cost_calculator).returns(calculator)
      @cart.shipping_costs
      
      calculator = mock()
      calculator.expects(:costs_for).with(@cart, :net_costs => true).once
      
      @cart.stubs(:shipping_cost_calculator).returns(calculator)
      
      @cart.shipping_costs(:net_costs => true)
    end
       
    context "without any articles" do
      it "knows that it is empty" do
        @cart.cart_items.should be_empty
        @cart.should be_empty
      end
    end
       
    context "with an article" do
      before(:each) do
        @cart.add_item(@article1, :quantity => 10)
      end
      
      it "should destroy empty cart_items" do
        @cart.cart_items.first.update_attribute :quantity, 0        
        @cart.cart_items.should be_empty
      end

      it "should be able to remove all occurences of an article in the cart" do
        # FIXME DRY?
        article1_count = @cart.cart_items.select {|ci| ci.item == @article1}.first.quantity
        @cart.item_count.should be(article1_count)
        proc {@cart.remove_item(@article1)}.should change(@cart, :item_count).by(-1 * article1_count)
        
        @cart.item_count.should be(0)
        
        @cart.add_item(@article1, :quantity => 10)
        proc {@cart.remove_item(@article1, :quantity => 100)}.should change(@cart, :item_count).to(0)
        @cart.cart_items.should be_empty
      end

      it "should be able to set the quantity of an article directly" do
        proc {@cart.update_item(@article1, :quantity => 5)}.should change(@cart, :item_count).to(5)
      end  
      
      it "JSON representation should include cart_items" do
        decoded = ActiveSupport::JSON.decode(@cart.to_json)
        decoded['cart']['cart_items'].should_not be_empty 
        # FIXME Test existence of other values like, total, coupons etc.
      end
    end
    
    context "adding coupon codes" do
      it "should show an error when adding an incorrect coupon code" do
        @cart.coupon_code = "incorrectcode"
        @cart.should_not be_valid        
        @cart.errors[:coupon_code].should_not be_nil
      end

      it "should add a coupon via update_coupons" do
        coupon = Coupon.make(:percent20off)
        @cart.coupon_code = coupon.code
        @cart.coupons.should be_empty
        @cart.save
        @cart.coupons.should include coupon
      end

      it "should only add one coupon of a kind" do
        coupon = Coupon.make(:percent20off)
        
        @cart.coupon_code = coupon.code
        @cart.coupons.should be_empty
        @cart.save
        @cart.reload
        
        @cart.coupons.should include coupon
        @cart.coupons.size.should == 1
        
        @cart.coupon_code = ""
        @cart.save
        @cart.reload
        
        @cart.coupons.size.should == 1
        @cart.coupon_code = coupon.code
        @cart.save
        @cart.reload

        @cart.coupons.size.should == 1
      end

      it "should not add a coupon if they are all used up" do
        coupon = Coupon.make(:percent20off)
        coupon.max_uses = -1
        coupon.save
        @cart.coupon_code = coupon.code
        @cart.coupons.should be_empty
        @cart.save
        @cart.reload
        @cart.coupons.size.should == 0
      end
    end
    
    context "with mutiple articles" do
      before(:each) do
        @article3 = Item.make(:price => 30.3)
        @cart.add_item(@article1, :quantity => 10)
        @cart.add_item(@article2, :quantity => 2)
        @cart.add_item(@article3, :quantity => 4)
      end

      it "should be able to calculate the sum" do
        @cart.item_sum.should be_close(10*10.0+2*20.0+4*30.3,0.01)
      end
      
      it "can clear all items and coupons from the cart" do
        @cart.cart_items.size.should be > 0
        a_cart_item = @cart.cart_items.last
        
        coupon = Coupon.make()
        @cart.coupons << coupon
        @cart.save!
        @cart.reload
        @cart.coupons.size.should be > 0
        a_coupon_use = @cart.coupon_uses.last
        
        @cart.clear!
        @cart.cart_items.size.should be 0
        @cart.coupons.size.should be 0

        CartItem.find_by_id(a_cart_item.id).should be_nil
        CouponUse.find_by_id(a_coupon_use.id).should be_nil
      end
      
      
      context "and coupons" do
        it "should calculate the sum with a 20% off coupon" do
          @cart.coupons << Coupon.make(:percent20off)
          @cart.total.should be_close(@cart.item_sum*0.8 + @cart.shipping_costs, 0.01)
        end
        
        it "should reduce items sum by 10" do
          @cart.coupons << Coupon.make(:euro10)
          @cart.total.should be_close(@cart.item_sum - 10 + @cart.shipping_costs, 0.01)
        end
        
        it "should be no shipping costs with a coupon" do
          @cart.shipping_costs.should be_close(8.90,0.01) 
          @cart.coupons << Coupon.make(:shipping)
          @cart.shipping_costs.should be_close(0,0.01) 
        end
        
        it "can not have a negative total" do
          @cart.total.should >(0)

          @cart.coupons << Coupon.make(:euro10, :discount_credit => @cart.total + 10)

          @cart.total.should be_close(0, 0.01)
        end
        
      end
    end
    
    context "automatic coupons" do
      it "adds coupons automatically which are valid (datewise) and are set to be enabled automatically at a certain total price of a cart" do
        cheap_product = Item.make(:price => 49.99)
        expensive_product = Item.make(:price => 50.01)

        intermediate_mock = mock
        
        Coupon.stubs(:valid).returns(intermediate_mock)
        
        @cart.clear!
        intermediate_mock.expects(:automatically_added_over).with(cheap_product.price).returns([])        
        @cart.add_item(cheap_product)
        @cart.coupons.size.should be 0
      
        @cart.clear!
        intermediate_mock.expects(:automatically_added_over).with(expensive_product.price).returns([Coupon.make])
        @cart.add_item(expensive_product)
        @cart.coupons.size.should be 1
      end
      
      it "never adds an automatic coupon twice" do
        coupon = Coupon.make(:value_of_automatic_add => 10)
        item = Item.make(:price => 10)
        
        @cart.clear!
        @cart.add_item(item)
        @cart.coupons.size.should be 1
        @cart.coupons.should include coupon
        
        @cart.add_item(item)
        @cart.coupons.size.should be 1
        @cart.coupons.should include coupon
      end
      
      it "it removes automatically added coupons that are not longer applicable from the cart whenever an item is removed" do
        coupon1 = Coupon.make(:value_of_automatic_add => 10)
        coupon2 = Coupon.make(:value_of_automatic_add => 15)
        
        item1 = Item.make(:price => 12)
        item2 = Item.make(:price =>  3)
        
        @cart.clear!
        @cart.add_item(item1)
        @cart.add_item(item2)
        @cart.coupons.size.should be 2
        @cart.coupons.should include(coupon1)
        @cart.coupons.should include(coupon2)
        
        @cart.remove_item(item2)
        @cart.coupons.size.should be 1
        @cart.coupons.should include(coupon1)
        
        @cart.remove_item(item1)
        @cart.coupons.size.should be 0
      end
      
      it "coupons reappear when the cart had enough items, the user then removed some so that the coupon wasn't automatically applicable anymore and then adds more items to the cart" do
        coupon = Coupon.make(:value_of_automatic_add => 10)
        
        item1 = Item.make(:price => 5)
        item2 = Item.make(:price => 6)
        item3 = Item.make(:price => 7)
        
        @cart.clear!
        @cart.add_item(item1)
        @cart.add_item(item2)
        @cart.remove_item(item2)
        @cart.add_item(item3)
        
        @cart.coupons.size.should be 1
        @cart.coupons.should include(coupon)
      end
      
      it "adds or removes the coupon when updating a cart item" do
        coupon = Coupon.make(:value_of_automatic_add => 10)
        item = Item.make(:price => 5)
        
        @cart.clear!
        @cart.add_item(item)
        @cart.coupons.size.should be 0
        
        @cart.update_item(item, :quantity => 2)
        @cart.coupons.size.should be 1
        @cart.coupons.should include(coupon)
        
        @cart.update_item(item, :quantity => 1)
        @cart.coupons.size.should be 0
      end
    end
    
  end
end
