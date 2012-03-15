class ShopBunny::CouponUse < ActiveRecord::Base
  belongs_to :cart
  belongs_to :coupon, :class_name => 'ShopBunny::Coupon'

  validates_presence_of :cart_id
  validates_presence_of :coupon_id
  validates_uniqueness_of :coupon_id, :scope => :cart_id
end
