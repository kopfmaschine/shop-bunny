# An item in the store
class Item < ActiveRecord::Base
  validates_presence_of :price
  validates_numericality_of :price
end

