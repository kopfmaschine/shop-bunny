# encoding: utf-8
require 'spec_helper'

describe CartsController do   
  
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
  
  # FIXME How can we refactor this test and keep it DRY?
  it "adds and removes items from a cart" do
    item1 = Item.make
    item2 = Item.make
    
    # Add item…
    put :update, :add_items => [item1, item2]
    # FIXME This 'map' sounds weird?
    assigns[:cart].cart_items.map(&:item).should == [item1, item2]
    response.should redirect_to(assigns[:cart])
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
      put :update, {:remove_items => [@item1]}, { :cart_id => @cart.id }
      # FIXME This 'map' sounds also weird?
      assigns[:cart].cart_items.map(&:item).should == [@item2]
      response.should redirect_to(assigns[:cart])
    end
  end
  
  it "shoul add correct coupon code" do
    coupon = Coupon.make(:shipping)
    put :update, :cart => { :coupon_code => coupon.code }
    cart = assigns[:cart]
    cart.coupons.should include(coupon)
    response.should redirect_to(assigns[:cart])
  end
  
  it "handles an incorrect coupon code" do
    coupon = Coupon.make(:shipping)
    put :update, :cart => { :coupon_code => "incorrectcode" }
    cart = assigns[:cart]
    cart.coupons.should_not include(coupon)
    response.should be_success
  end
  
  # it "handles a expired coupon code" do
  #   coupon = Coupon.make(:shipping)
  #   put :update, :cart => { :coupon_code => coupon.code }
  #   cart = assigns[:cart]
  #   cart.coupons.should_not include(coupon)
  #   response.should redirect_to(assigns[:cart])    
  # end
end
