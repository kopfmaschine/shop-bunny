require 'spec_helper'

describe "On the cart page" do
  def add_coupon_code(code)
    fill_in 'Coupon code', :with => code
    click_button 'Add code'
  end

  def add_item(item)
    within "#item_#{item.id}" do
      click_link "Add to cart"
    end
  end

  def remove_item(item)
    click_link "Remove item #{item.id}"
  end

  def assert_no_errors
    find('#error_messages').should have_no_selector('li')
  end

  before do
    @item = Item.make(:price => 10)
    visit cart_path
  end

  it "shows the expected price numbers for an empty cart" do
    find('#price-item-sum').should have_content("$0.0")
    find('#price-shipping-costs').should have_content("$8.90")
    find('#price-total').should have_content("$8.90")
  end

  describe "adding an item to the cart" do
    it "updates the price" do
      add_item(@item)
      find('#price-total').should have_content("$18.90")
    end
  end

  describe "removing an item from the cart" do
    it "resets the price" do
      add_item(@item)
      remove_item(@item)
      find('#price-total').should have_content("$8.90")
    end
  end

  describe "adding coupons" do
    it "does not show an error if the code is ok" do
      coupon = ShopBunny::Coupon.make
      add_coupon_code(coupon.code)
      assert_no_errors
    end

    it "does not show an error for one-time coupons" do
      coupon = ShopBunny::Coupon.make(:max_uses => 1)
      add_coupon_code(coupon.code)
      assert_no_errors
    end

    it "lists the newly added coupon" do
      coupon = ShopBunny::Coupon.make(:title => "New Coupon")
      add_coupon_code(coupon.code)
      find('#your_coupons').should have_content("New Coupon")
    end

    it "applies the discout credit to the shipping costs" do
      coupon = ShopBunny::Coupon.make(:discount_credit => 5)
      add_coupon_code(coupon.code)
      find('#price-total').should have_content("$3.90")
    end

    it "shows an error if the code is unknown" do
      add_coupon_code('unknown')
      find('#error_messages').should have_content("The provided code is unknown or invalid")
    end

    it "shows an error if the code is expired" do
      expired = ShopBunny::Coupon.make(:expired)
      add_coupon_code(expired.code)
      find('#error_messages').should have_content("The provided code has expired")
    end

    it "shows an error if the the maximum use count is exceeded" do
      coupon = ShopBunny::Coupon.make(:max_uses => 1)
      # use up coupon
      add_coupon_code(coupon.code)
      assert_no_errors
      # try to the same coupon again in a new session
      reset_session!
      visit cart_path
      add_coupon_code(coupon.code)
      find('#error_messages').should have_content("The number of uses for this code has been exceeded")
    end
  end
end

