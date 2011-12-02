$:.push File.expand_path("../lib", __FILE__)
require "shop_bunny/version"
Gem::Specification.new do |s|
  s.name = "shop_bunny"
  s.version     = ShopBunny::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ["kopfmaschine.com"]
  s.email = ["jan@kopfmaschine.com"]
  s.homepage = "http://kopfmaschine.com"
  s.summary = "A shop template for your needs"
  s.description = "A simple shop gem that integrates a cart and coupons functionality"
  s.add_dependency "rails", "~> 3.1.3"

  s.required_rubygems_version = ">= 1.3.6"
  s.has_rdoc = true
  s.files = Dir["{app,config,db,lib}/**/*"] + ["Rakefile", "README"]
  s.test_files = Dir["spec/**/*"]
  s.require_path = 'lib'
  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "machinist"
  s.add_development_dependency "mocha"
  s.add_development_dependency "shoulda-matchers"
  s.add_development_dependency "capybara"
end
