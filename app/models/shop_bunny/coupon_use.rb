class ShopBunny::CouponUse < ActiveRecord::Base
  belongs_to :cart
  belongs_to :coupon, :class_name => 'ShopBunny::Coupon'

  validates_presence_of :cart_id
  validates_presence_of :coupon_id
end
