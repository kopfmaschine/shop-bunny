module ShopBunny
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path("../../../../", __FILE__)
    
    def copy_files
     puts Dir['.']
     directory 'db/migrate'
    end
  end
end
