# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'activegraphql/version'

Gem::Specification.new do |spec|
  spec.name          = 'activegraphql'
  spec.version       = ActiveGraphql::VERSION
  spec.authors       = ['Wakoopa']
  spec.email         = ['info@wakoopa.com']

  spec.summary       = %q{Ruby client for GraphQL services}
  spec.description   = %q{}
  spec.homepage      = 'https://github.com/wakoopa/active-graphql'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_dependency 'hashie', '~> 3.4'
  spec.add_dependency 'activesupport', '~> 4.2'
  spec.add_dependency 'httparty', '~> 0.13'
end
