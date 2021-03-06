# encoding: utf-8
module ShopBunny
  require 'shop_bunny/engine' if defined?(Rails) && Rails::VERSION::MAJOR == 3
  require 'shop_bunny/shipping_cost_calculator'
  require 'shop_bunny/cart_module'
  require 'shop_bunny/cart_controller_module'
  require 'shop_bunny/controller_helpers'
  
  mattr_accessor :item_model_class_name
  @@item_model_class_name = 'Item'
    
  mattr_accessor :shipping_cost_calculator
  @@shipping_cost_calculator = ShopBunny::ShippingCostCalculator
  
  mattr_accessor :cart_item_enhancements
  @@cart_item_enhancements ||= []

  def self.table_name_prefix
    ''
  end

  # This is the default way to setup ShopBunny and is used in the 
  # initializer which gets generated by `rails generate shop_bunny:install`
  def self.setup
    yield self
  end
end
