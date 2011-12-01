require 'spec_helper'

describe ShopBunny::CouponUse do
  it { should validate_presence_of :cart_id }
  it { should validate_presence_of :coupon_id }  
end
