Gem::Specification.new do |gem|
  gem.name          = "yammer-cli"
  gem.version       = "0.2.0"
  gem.authors       = ["Joe Wright"]
  gem.email         = ["joe.wright@noventech.com"]
  gem.description   = "A yammer command line client."
  gem.summary       = "A yammer command line client."
  gem.homepage      = "http://www.noventech.com"

  gem.files         = `git ls-files`.split($/)
  gem.executables   << 'yammer'
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency 'yammer'
  gem.add_runtime_dependency 'rainbow'
  gem.add_runtime_dependency 'oauth'

  gem.add_development_dependency 'bundler'
  gem.add_development_dependency 'rake'
end
