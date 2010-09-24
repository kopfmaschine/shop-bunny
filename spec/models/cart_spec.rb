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
  end
end
