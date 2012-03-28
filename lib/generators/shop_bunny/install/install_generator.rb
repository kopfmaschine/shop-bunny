require 'rails/generators'
module ShopBunny  
  class InstallGenerator < Rails::Generators::Base
    include Rails::Generators::Migration
    class_option :model, :type => :boolean, :default => true, :desc => "copy model templatefile."

    def copy_files
      puts Dir['.']
      copy_file "#{self.class.source_root}/initializer.rb", 'config/initializers/shop_bunny.rb'
      copy_file "#{self.class.source_root}/shopbunny_model_template.rb", 'app/models/cart.rb' if options.model?
    end

    def self.source_root
      @source_root ||= File.join(File.dirname(__FILE__), 'templates')
    end

    def create_migrations
      Dir["#{self.class.source_root}/../../../../../db/migrate/*.rb"].sort.each do |filepath|
        p filepath
        name = File.basename(filepath)
        copy_file filepath, "db/migrate/#{name}"
      end
    end

  end
end

# TODO Write a generator test
