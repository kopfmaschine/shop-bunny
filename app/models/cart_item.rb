class CartItem < ActiveRecord::Base
  belongs_to :cart
  belongs_to :item
  
  validates_presence_of :cart_id
  validates_presence_of :item_id
  validates_numericality_of :quantity
  
  before_validation :set_default_quantity


  private
  def set_default_quantity
    self.quantity ||= 0
  end
end
