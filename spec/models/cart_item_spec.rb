require 'spec_helper'
  
describe CartItem do
  before(:each) do
    @cart_item = CartItem.make
    @cart_item.item = Item.new
  end

  it {should belong_to :cart}
  it {should_not belong_to :item}
  it {should validate_presence_of :cart_id }
  it {should validate_numericality_of(:quantity)}
  
  it "knows it's total price" do
    @cart_item.item.price = 10

    @cart_item.total_price.should be_close(10, 0.001)
    
    @cart_item.quantity = 5
    
    @cart_item.total_price.should be_close(50, 0.001)
  end
  
  describe "item marshalling" do
    it "marshalls it's item and reloads it on request" do
      item = Item.make
      @cart_item.item = item
      @cart_item.raw_item.should == item.to_json
      @cart_item.item.should == item
    end
    
    it "is possible to create an item with an item with create or new" do
      item = Item.make
      cart_item = CartItem.new(:item => item)
      cart_item.item.should == item
    end
  end
end
