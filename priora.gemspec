
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'priora/version'

Gem::Specification.new do |spec|
  spec.name          = 'priora'
  spec.version       = Priora::VERSION
  spec.authors       = ['Eliav Lavi']
  spec.email         = ['eliavlavi@gmail.com']

  spec.summary       = 'An object prioritization helper'
  spec.description   = 'Priora helps in prioritizing a collection of objects according to your needs.'
  spec.homepage      = 'http://www.github.com/eliavlavi/priora'
  spec.license       = 'MIT'
  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'coveralls'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
