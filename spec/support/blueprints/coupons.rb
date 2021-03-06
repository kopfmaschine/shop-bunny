# encoding: utf-8
ShopBunny::Coupon.blueprint do
#  removes_tax false
  discount_percentage 1.0
  discount_credit 0.0
#  removes_shipping_cost false
#  bonus_article_id 1
#  valid_from "2010-09-15"
#  valid_until "2010-09-15"
  title "default"
  code { "secretcode#{TestSerialNumber.next}" }
  state 'active'
end

ShopBunny::Coupon.blueprint(:shipping) do
  removes_shipping_cost true
  title "No Shipping"
  code { "shipping#{TestSerialNumber.next}" }
  state 'active'
end

ShopBunny::Coupon.blueprint(:percent20off) do
  discount_percentage 0.8
  title "20% Off!"
  code "percent20off#{TestSerialNumber.next}"
  state 'active'
end

ShopBunny::Coupon.blueprint(:euro10) do
  discount_credit 10.0  
  title "10€ abzug"
  code "euro10#{TestSerialNumber.next}"
  state 'active'
end

ShopBunny::Coupon.blueprint(:daterange) do
  valid_from Time.local(2010,9,10)
  valid_until Time.local(2010,9,20)
  title "Datumscoupon"
  code "daterange#{TestSerialNumber.next}"
  state 'active'
end

ShopBunny::Coupon.blueprint(:expired) do
  valid_from 3.days.ago
  valid_until 2.days.ago
  title "Datumscoupon"
  code "daterange#{TestSerialNumber.next}"
  state 'active'
end