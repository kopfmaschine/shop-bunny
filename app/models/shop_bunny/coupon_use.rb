class ShopBunny::CouponUse < ActiveRecord::Base
  belongs_to :cart
  belongs_to :coupon, :class_name => 'ShopBunny::Coupon'

  validates_presence_of :cart_id
  validates_presence_of :coupon_id
  validates_uniqueness_of :coupon_id, :scope => :cart_id
  validate :minimum_order_value_reached

  protected
  def minimum_order_value_reached
    errors.add(:base, :minimun_order_value) unless coupon.valid_for?(cart)
  end
end
