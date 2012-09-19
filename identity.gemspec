Gem::Specification.new do |s|
  s.name        = 'identity'
  s.version     = '1.0.2'
  s.date        = '2012-09-17'
  s.summary     = "Ruby ufp Identity Library"
  s.description = "A Ruby library for integrations with ufp Identity"
  s.authors     = ["Richard Levenberg"]
  s.email       = 'richardl@ufp.com'
  s.files       = Dir["**/*"] - Dir["*.gem"] - Dir["*.pem"] - Dir["Gemfile.lock"]
  s.homepage    = 'https://www.ufp.com'
  s.rubyforge_project = "identity"
  s.require_paths = ["lib", "lib/warden"]

  s.add_dependency("rest-client", "~> 1.6.7")
  s.add_dependency("xml-simple", "~> 1.1.1")
end