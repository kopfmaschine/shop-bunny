# An item in the store
class Item < ActiveRecord::Base
  validates_presence_of :price
  validates_numericality_of :price
  
  # The host app can return a hash here that get's serialized on the
  # CartItems and Items get instanstiated of this hash when CartItem#item is 
  # called.
  # The default implementation uses the attributes hash of ActiveRecord
  def shop_bunny_json_attributes
    attributes
  end
end