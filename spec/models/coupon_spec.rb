require 'spec_helper'

describe Coupon do
  it {should validate_presence_of :title }
  it {should validate_presence_of :code }
end
