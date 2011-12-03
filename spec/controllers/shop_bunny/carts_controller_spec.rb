# encoding: utf-8
require 'spec_helper'

describe ShopBunny::CartsController do
  include ShopBunny

  # overwriting helper methods and pass :use_route => 'shop_bunny' to make it work
  # Adapted from http://stackoverflow.com/questions/5200654
  [:get, :put, :post, :delete].each { |verb|
    define_method(verb) do |*args|
      action, parameters, session, flash = args
      parameters ||= {}
      parameters[:use_route] ||= 'shop_bunny' if parameters.is_a?(Hash)
      super(action, parameters, session, flash) 
    end
  }

  before(:each) do
    @cart = Cart.make
  end
  
  it "shows a new cart" do
    proc { 
      get :show
    }.should change(Cart, :count).by(1)
    assigns[:cart].should_not be_nil
    response.should be_success    
  end
  
  it "shows an existing cart" do    
    # Here the last hash sets session[:cart_id] to @cart.id
    get :show, {}, { :cart_id => @cart.id }
    assigns[:cart].should == @cart
    response.should be_success
  end
  
  it "should add an item to a cart" do
    item1 = Item.make        
    # Add item…
    get :add_item, :item_id => item1
    # FIXME This 'map' sounds weird?
    assigns[:cart].cart_items.map(&:item).should == [item1]
    response.should redirect_to cart_path
  end
  
  context "with items in cart" do
    before(:each) do
      @cart = Cart.make
      @cart.add_item(@item1 = Item.make)
      @cart.add_item(@item2 = Item.make)  
    end
    
    it "should hold two items" do
      get :show, {}, { :cart_id => @cart.id }
      assigns[:cart].cart_items.map(&:item).should == [@item1, @item2]
    end
    
    it "should remove an item" do
      # Remove item…
      get :remove_item, {:item_id => @item1}, { :cart_id => @cart.id }
      # FIXME This 'map' sounds also weird?
      assigns[:cart].cart_items.map(&:item).should == [@item2]
      response.should redirect_to cart_path
    end
    
    it 'should update the quantity of a cart item' do
      cart_item = @cart.cart_items.first
      put :update, {:cart => { :cart_items_attributes => [{:id => cart_item.id, :quantity => 42 }]}}, {:cart_id => @cart.id}
      assigns[:cart].cart_items.first.quantity.should be(42)
      response.should redirect_to cart_path
    end
    
    it "can clear the cart" do
      get :show, {}, { :cart_id => @cart.id }
      
      session[:cart_id].should_not be_nil
      controller.send(:clear_cart)
      session[:cart_id].should be_nil
    end
  end
  
  it "should add correct coupon code" do
    coupon = Coupon.make(:shipping)
    put :update, :cart => { :coupon_code => coupon.code }
    cart = assigns[:cart]
    cart.coupons.should include(coupon)
    response.should redirect_to cart_path
  end
  
  it "handles an incorrect coupon code" do
    coupon = Coupon.make(:shipping)
    put :update, :cart => { :coupon_code => "incorrectcode" }
    cart = assigns[:cart]
    cart.coupons.should_not include(coupon)
    response.should be_success
  end
end
