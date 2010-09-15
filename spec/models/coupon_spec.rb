require 'spec_helper'

describe Coupon do
  it {should validate_presence_of :title }
  it {should validate_presence_of :code }
  
  it "should be valid within the given range" do
    coupon = Coupon.make(:daterange)
    Time.stubs(:now).returns(Time.local(2010,9,14).to_time)
    coupon.should_not be_expired
    Time.stubs(:now).returns(Time.local(2010,2,2).to_time)
    coupon.should be_expired
    Time.stubs(:now).returns(Time.local(2010,9,22).to_time)
    coupon.should be_expired
  end
end
