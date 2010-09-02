require 'spec_helper'

describe Cart do
  it { should have_many :cart_items}
  it { should validate_presence_of :owner_id }
  
  context "A Cart" do
    before(:each) do
      @cart = Cart.make_unsaved
    end
    
    
    
    it "should be able to add articles" do
      puts @cart.inspect
      proc {@cart.add :article_id => 1, :quantity => 1 }.should change(@cart, :items).by(1)
    end
    
  end
end
