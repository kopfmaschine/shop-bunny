require 'spec_helper'

describe CartItem do
  
  before(:each) do
    @cart_item = CartItem.make
  end

  it {should belong_to :cart}
  it {should validate_presence_of :cart_id }
  it {should validate_presence_of :item_id }
  it {should validate_numericality_of(:quantity)}
  
  it "knows it's total price" do
    @cart_item.item.price = 10

    @cart_item.total_price.should be_close(10, 0.001)
    
    @cart_item.quantity = 5
    
    @cart_item.total_price.should be_close(50, 0.001)
  end
end
