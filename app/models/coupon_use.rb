class CouponUse < ActiveRecord::Base
  belongs_to :cart
  belongs_to :coupon

  validates_presence_of :cart_id
  validates_presence_of :coupon_id
end
