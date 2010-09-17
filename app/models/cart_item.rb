class CartItem < ActiveRecord::Base
  belongs_to :cart
  belongs_to :item, :class_name => ShopBunny.item_model_class_name
  
  validates_presence_of :cart_id
  validates_presence_of :item_id
  validates_numericality_of :quantity
  
  before_validation :set_default_quantity
  after_update :destroy_if_empty
  # TODO attr_accessible :quantity
  

  private
  
  def set_default_quantity
    self.quantity ||= 0
  end
  
  def destroy_if_empty
    self.destroy if quantity.to_i <= 0
  end
end
