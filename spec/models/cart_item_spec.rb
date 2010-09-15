require 'spec_helper'

describe CartItem do

  it {should belong_to :cart}
  it {should validate_presence_of :cart_id }
  it {should validate_presence_of :item_id }
  it {should validate_numericality_of(:quantity)}
  
  
end
