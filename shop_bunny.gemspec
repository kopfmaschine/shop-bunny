Gem::Specification.new do |s|
  s.name = "shop_bunny"
  s.version = 0.7
  s.platform = Gem::Platform::RUBY
  s.authors = ["kopfmaschine.com"]
  s.email = ["jan@kopfmaschine.com"]
  s.homepage = "http://kopfmaschine.com"
  s.summary = "A shop template for your needs"
  s.description = "A simple shop gem that integrates a cart and coupons functionality"

  s.required_rubygems_version = ">= 1.3.6"

  # If you need to check in files that aren't .rb files, add them here
  s.files = Dir["{lib}/**/*.rb", "bin/*", "LICENSE", "*.md"]
  s.require_path = 'lib'
end