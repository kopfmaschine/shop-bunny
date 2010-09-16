# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

# Dummy data for development
if Rails.env.development?
  3.times { |i| Item.create! :price => i }
  3.times { |i| 
    c = Coupon.new
    c.code = "code#{i}"
    c.title = "10% discount coupon #{i}"
    c.discount_percentage = 0.9
    c.save!
  }
end