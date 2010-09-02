class Cart < ActiveRecord::Base
  has_many :cart_items
  
  validates_presence_of :owner_id
  
  def items
    self.cart_items
  end
  
  def add(options)
    self.cart_items.create(options)
  end
  
end
