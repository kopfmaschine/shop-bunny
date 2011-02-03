# encoding: utf-8
module ShopBunny
  require 'shop_bunny/engine' if defined?(Rails) && Rails::VERSION::MAJOR == 3
  require 'shop_bunny/shipping_cost_calculator'
  require 'shop_bunny/cart_module'
  require 'shop_bunny/cart_controller_module'
  
  mattr_accessor :item_model_class_name
  @@item_model_class_name = 'Item'
    
  mattr_accessor :shipping_cost_calculator
  @@shipping_cost_calculator = ShopBunny::ShippingCostCalculator
  
  mattr_accessor :cart_item_enhancements
  @@cart_item_enhancements ||= []
  
  # This is the default way to setup ShopBunny and is used in the 
  # initializer which gets generated by `rails generate shop_bunny:install`
  def self.setup
    yield self
    
    item_class = ShopBunny.item_model_class_name.constantize
    
    unless item_class.method_defined?(:as_json_with_included_id)
      item_class.class_eval do
        def shop_bunny_json_options(options)
          options ||= {}
          options[:methods] ||= []
          if options[:methods].kind_of?(Array)
            options[:methods] += [:id]
          else
            options[:methods] = [options[:methods], :id]
          end
          options[:methods].uniq!
          options
        end
      
        def as_json_with_included_id(options = {})
          as_json_without_included_id(shop_bunny_json_options(options))
        end
        alias_method_chain :as_json, :included_id
      end
    end
  end
end
