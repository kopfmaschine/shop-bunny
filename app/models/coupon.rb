class Coupon < ActiveRecord::Base
  has_many :coupon_uses
  has_many :carts, :through => :coupon_uses

  validates_presence_of :code
  validates_presence_of :title
end
