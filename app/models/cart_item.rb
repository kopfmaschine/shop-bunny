class CartItem < ActiveRecord::Base
  belongs_to :cart
  validates_presence_of :cart_id
  validates_presence_of :article_id
  validates_numericality_of :quantity
end
