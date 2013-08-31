Gem::Specification.new do |s| 
  s.name = "basic_load_test"
  s.version = "0.1"
  s.author = "Stephen O'Donnell"
  s.email = "stephen@betteratoracle.com"
  s.homepage = "http://betteratoracle.com"
  s.platform = Gem::Platform::RUBY
  s.summary = "A gem to generate a specified number of calls per second to a method, ideal for load testing database calls or webservices"
  s.files = (Dir.glob("{test,lib}/**/*") + Dir.glob("[A-Z]*")).reject{ |fn| fn.include? "temp" }

  s.require_path = "lib"
  s.description  = "A gem to generate a specified number of calls per second to a method, ideal for load testing database calls or webservices"
#  s.autorequire = "name"
#  s.test_files = FileList["{test}/**/*test.rb"].to_a
  s.has_rdoc = true
#  s.extra_rdoc_files = ["README.md"]
#  s.add_dependency("dependency", ">= 0.x.x")
end