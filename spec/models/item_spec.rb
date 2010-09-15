require 'spec_helper'

describe Item do
  it {should validate_presence_of :price}
  it {should validate_numericality_of :price}
end
