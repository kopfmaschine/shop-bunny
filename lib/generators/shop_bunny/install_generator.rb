module ShopBunny  
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path("../../../../", __FILE__)
    class_option :controller, :type => :boolean, :default => true, :desc => "copy controller templatefile."
    class_option :model, :type => :boolean, :default => true, :desc => "copy model templatefile."
    
    
    def copy_files
     puts Dir['.']
     directory 'db/migrate'
     copy_file 'config/initializers/shop_bunny.rb'
     copy_file 'lib/generators/shop_bunny/templates/shopbunny_controller_template.rb', 'app/controllers/carts_controller.rb' if options.controller?
     copy_file 'lib/generators/shop_bunny/templates/shopbunny_model_template.rb', 'app/models/cart.rb' if options.model?
    end
  end
end

# TODO Write a generator test
