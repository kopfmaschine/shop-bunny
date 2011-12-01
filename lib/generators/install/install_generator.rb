module ShopBunny  
  class InstallGenerator < Rails::Generators::Base
    include Rails::Generators::Migration
    source_root File.expand_path("../../../../", __FILE__)
    class_option :model, :type => :boolean, :default => true, :desc => "copy model templatefile."

    def copy_files
      puts Dir['.']
      copy_file 'lib/generators/install/templates/initializer.rb', 'config/initializers/shop_bunny.rb'
      copy_file 'lib/generators/install/templates/shopbunny_model_template.rb', 'app/models/cart.rb' if options.model?
    end

    def create_migrations
      Dir["#{self.class.source_root}/migrations/*.rb"].sort.each do |filepath|
        name = File.basename(filepath)
        migration_template "migrations/#{name}", "db/migrate/#{name.gsub(/^\d+_/,'')}"
      end
    end

  end
end

# TODO Write a generator test
