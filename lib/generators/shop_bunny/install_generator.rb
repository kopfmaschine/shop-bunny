module ShopBunny  
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path("../../../../", __FILE__)

    def copy_files
     puts Dir['.']
     directory 'db/migrate'
     copy_file 'config/initializers/shop_bunny.rb'
    end
  end
end

# TODO Write a generator test
