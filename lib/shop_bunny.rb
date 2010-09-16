module ShopBunny
  require 'engine' if defined?(Rails) && Rails::VERSION::MAJOR == 3
  require 'default_shipping_cost_calculator'
end
