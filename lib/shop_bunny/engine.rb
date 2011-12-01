module ShopBunny
  class Engine < Rails::Engine
    isolate_namespace ShopBunny

    # Config defaults
    config.mount_at = '/'

    # Check the gem config
    initializer "shop_bunny.check_mount_point" do |app|
      # make sure mount_at ends with trailing slash
      config.mount_at += '/' unless config.mount_at.last == '/'
    end

    initializer "shop_bunny.add_controller_helpers" do |app|
      ActiveSupport.on_load(:action_controller) do
        include ShopBunny::ControllerHelpers
      end
    end
  end
end
