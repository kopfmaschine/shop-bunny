require 'spec_helper'

describe ShopBunny::CouponUse do
  it { should validate_presence_of :cart_id }
  it { should validate_presence_of :coupon_id }

  it "validates uniqueness of the cart and coupon tuple" do
    cart = Cart.make
    coupon = ShopBunny::Coupon.make
    ShopBunny::CouponUse.create!(:coupon => coupon, :cart => cart)
    expect {
      ShopBunny::CouponUse.create!(:coupon => coupon, :cart => cart)
    }.to raise_error(ActiveRecord::RecordInvalid)
  end
end
