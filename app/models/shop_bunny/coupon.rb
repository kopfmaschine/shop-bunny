class ShopBunny::Coupon < ActiveRecord::Base
  InvalidEvent = Class.new(NoMethodError)
  has_many :coupon_uses, :dependent => :destroy, :class_name => 'ShopBunny::CouponUse'
  has_many :carts, :through => :coupon_uses
  belongs_to :bonus_article, :class_name => ShopBunny.item_model_class_name

  validates_presence_of :code
  validates_uniqueness_of :code
  validates_presence_of :title

  after_initialize { self.state ||= 'inactive' }
  after_save :touch_cart
  after_destroy :touch_cart

  # TODO Add self destruction when coupon has expired?

  scope :valid, lambda {{:conditions => ['(coupons.valid_from IS NULL OR coupons.valid_from <= ?) AND (coupons.valid_until IS NULL OR coupons.valid_until >= ?) AND coupons.state = ?', Time.now, Time.now, 'active']}}
  scope :automatically_added_over, lambda {|value| {:conditions => ['value_of_automatic_add <= ?', value]}}

  def expired?
    not_yet_valid? || has_expired?
  end

  # FIXME rename?
  def not_yet_valid?
    Time.now < self.valid_from if self.valid_from 
  end

  def has_expired?
    Time.now > self.valid_until if self.valid_until 
  end

  def redeemable?
    !not_yet_valid? && !has_expired? && state == 'active'
  end

  def activate!
    raise InvalidEvent unless state == 'inactive'
    self.state = 'active'
  end

  def redeem!
    raise InvalidEvent unless redeemable?
    self.state = 'redeemed'
  end

  protected
  def touch_cart
    carts.each {|cart| cart.touch}
  end
end
