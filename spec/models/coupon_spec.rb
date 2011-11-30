require 'spec_helper'

describe Coupon do
  subject { Coupon.make }  
  it {should validate_presence_of :title }
  it {should validate_presence_of :code }
  it {should validate_uniqueness_of :code }
  
  it "should not be expired by default" do
    Coupon.make.should_not be_expired
  end
  
  it "should be valid within the given range" do
    coupon = Coupon.make(:daterange)
    Time.stubs(:now).returns(Time.local(2010,9,14).to_time)
    coupon.should_not have_expired
    coupon.should_not be_not_yet_valid
    coupon.should be_redeemable
    Time.stubs(:now).returns(Time.local(2010,2,2).to_time)
    coupon.reload.should_not have_expired
    coupon.should be_not_yet_valid
    coupon.should_not be_redeemable
    Time.stubs(:now).returns(Time.local(2010,9,22).to_time)
    coupon.should have_expired
    coupon.should_not be_redeemable
    coupon.should_not be_not_yet_valid
  end

  describe "#state" do
    it "is inactive by default" do
      Coupon.new.state.should == 'inactive'
    end

    it "can be overwritten" do
      Coupon.new(:state => 'active').state.should == 'active'
      Coupon.make(:state => 'redeemed').state.should == 'redeemed'
      Coupon.make(:state => 'inactive').state.should == 'inactive'
    end

    describe "#activate!" do
      it "changes the state from inactive to active" do
        coupon = Coupon.make(:state => 'inactive')
        coupon.activate!
        coupon.state.should == 'active'
      end

      it "fails for all other states" do
        %w(active redeemed).each do |state|
          lambda { Coupon.make(:state => state).activate! }.should raise_error(Coupon::InvalidEvent)
        end
      end

      it "does not save the record" do
        coupon = Coupon.new
        coupon.activate!
        coupon.should be_new_record
      end
    end

    describe "#redeem!" do
      it "changes the state from active to redeemed" do
        coupon = Coupon.make(:state => 'active')
        coupon.redeem!
        coupon.state.should == 'redeemed'
      end

      it "fails for all other states" do
        %w(inactive redeemed).each do |state|
          lambda { Coupon.make(:state => state).redeem! }.should raise_error(Coupon::InvalidEvent)
        end
      end

      it "fails if redeemable? returns false" do
        lambda {
          coupon = Coupon.make(:state => 'active')
          coupon.stubs(:redeemable?).returns(false)
          coupon.redeem!
        }.should raise_error
      end

      it "does not save the record" do
        coupon = Coupon.new(:state => 'active')
        coupon.redeem!
        coupon.should be_new_record
      end
    end
  end

  describe "#redeemable?" do
    it "is false by default" do
      Coupon.new.redeemable?.should be_false
    end

    it "is only true if state is active" do
      %w(inactive active redeemed).each do |state|
        Coupon.make(:state => state).redeemable?.should == (state == 'active')
      end
    end
  end

  context "scopes" do
    it "can find the valid coupons" do
      Time.stubs(:now).returns(Time.local(2010,9,22,14,31).to_time)
      
      valid_coupon = Coupon.make
      valid_coupon.valid_from = Time.local(2010,9,22,14,30).to_datetime
      valid_coupon.valid_until = Time.local(2010,9,25,17,30).to_datetime
      valid_coupon.save!
      
      invalid_coupon1 = Coupon.make
      invalid_coupon1.valid_from = Time.local(2010,9,21,10,30).to_datetime
      invalid_coupon1.valid_until = Time.local(2010,9,22,14,29).to_datetime
      invalid_coupon1.save!
      
      invalid_coupon2 = Coupon.make
      invalid_coupon2.valid_from = Time.local(2010,9,25,17,31).to_datetime
      invalid_coupon2.valid_until = Time.local(2010,9,26,15,00).to_datetime
      invalid_coupon2.save!

      inactive_coupon = Coupon.make(:state => 'inactive')
      
      coupon_without_dates = Coupon.make(:valid_from => nil, :valid_until => nil)
      
      Coupon.valid.size.should be 2
      Coupon.valid.should include valid_coupon
      Coupon.valid.should include coupon_without_dates

      (Coupon.all - Coupon.valid).should include inactive_coupon
    end
    
    it "can find coupons with an automatic add value less than the given value" do
      coupon_without_automatic_add_value = Coupon.make(:value_of_automatic_add => nil)
      
      coupon_with_low_automatic_add_value = Coupon.make(:value_of_automatic_add => 10.50)
      
      coupon_with_high_automatic_add_value = Coupon.make(:value_of_automatic_add => 50)
      
      result = Coupon.automatically_added_over(10.50)
      result.size.should be 1
      result.should include coupon_with_low_automatic_add_value
      
      result = Coupon.automatically_added_over(49.99)
      result.size.should be 1
      result.should include coupon_with_low_automatic_add_value
      
      result = Coupon.automatically_added_over(50)
      result.size.should be 2
      result.should include coupon_with_low_automatic_add_value
      result.should include coupon_with_high_automatic_add_value
    end
  end
end
