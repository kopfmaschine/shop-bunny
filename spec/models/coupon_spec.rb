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
    coupon.should_not be_expired
    Time.stubs(:now).returns(Time.local(2010,2,2).to_time)
    coupon.should be_expired
    Time.stubs(:now).returns(Time.local(2010,9,22).to_time)
    coupon.should be_expired
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
      
      coupon_without_dates = Coupon.make(:valid_from => nil, :valid_until => nil)
      
      Coupon.valid.size.should be 2
      Coupon.valid.should include valid_coupon
      Coupon.valid.should include coupon_without_dates
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
