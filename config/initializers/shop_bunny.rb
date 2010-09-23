# encoding: utf-8
# This is where you can customize the innards of ShopBunny.
ShopBunny.setup do  |config|
  # ShopBunny.item_model_class_name should return the name of the class of
  # which the items/products/things in your store are an instance of.
  # The default is 'Item'
  #
  # config.item_model_class_name = 'Product'  

  # ShopBunny.shipping_cost_calculator should return a class or module that
  # has a method 'costs_for(cart)' which returns a float (the shipping cost).
  # Note: You may also customize this behaviour by overwriting 
  # Cart#shipping_cost_calculator
  # The default is ShopBunny::ShippingCostCalculator
  #
  # config.shipping_cost_calculator = MyShippingCostCalculator
  
end
