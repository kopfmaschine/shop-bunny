class Coupon < ActiveRecord::Base
  has_many :coupon_uses, :dependent => :destroy
  has_many :carts, :through => :coupon_uses

  validates_presence_of :code
  validates_uniqueness_of :code
  validates_presence_of :title
  
  after_save :touch_cart
  after_destroy :touch_cart
  
  # TODO Add self destruction when coupon has expired?
  
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
  
  protected
  def touch_cart
    carts.each {|cart| cart.touch}
  end
end
