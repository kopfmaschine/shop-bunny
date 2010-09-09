    require 'spec_helper'

describe Cart do
  it { should have_many :cart_items}
  it { should validate_presence_of :owner_id }
  
  context "A Cart" do
    before(:each) do
      @cart = Cart.make
    end
    
    
    
    it "should be able to add articles" do
      proc {@cart.add :article_id => 1, :quantity => 1 }.should change(@cart, :item_count).by(1)
      @cart.items.size.should be(1)
      proc {@cart.add :article_id => 2, :quantity => 1 }.should change(@cart, :item_count).by(1)
      @cart.items.size.should be(2)
      proc {@cart.add :article_id => 1, :quantity => 3 }.should change(@cart, :item_count).by(3)
      @cart.items.size.should be(2)
    end
   
    context "with an article" do
      before(:each) do
        @cart.add :article_id => 1, :quantity => 10
      end

      it "should be able to remove articles" do
        proc {@cart.remove :article_id => 1, :quantity => 1}.should change(@cart, :item_count).by(-1)
        proc {@cart.remove :article_id => 1, :quantity => 100}.should change(@cart, :item_count).to(0)
      end

      it "should be able to set the quantity of an article directly" do
        proc {@cart.set :article_id => 1, :quantity => 5}.should change(@cart, :item_count).to(5)
      end
    end
  end
end
