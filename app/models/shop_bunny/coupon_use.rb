class ShopBunny::CouponUse < ActiveRecord::Base
  belongs_to :cart
  belongs_to :coupon, :class_name => 'ShopBunny::Coupon'

  validates_presence_of :cart_id
  validates_presence_of :coupon_id
  
  after_save :touch_cart
  after_destroy :touch_cart
  
  protected
  def touch_cart
    cart.touch if cart
  end
end
