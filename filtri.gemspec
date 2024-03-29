# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'filtri/version'

Gem::Specification.new do |spec|
  
  spec.name          = "filtri"
  spec.version       = Filtri::VERSION
  spec.authors       = ["karl l"]
  spec.email         = ["karl@ninjacontrol.com"]
  spec.date          = '2013-04-07'
  spec.summary       = "A tiny tool for text substitution"
  spec.description   = "Filtri is a tool that simplifies the work of applying multiple substitution rules to a string."
  spec.homepage      = "https://github.com/karlll/filtri/"
  spec.license       = "MIT"

  spec.required_ruby_version = '>= 1.9.3'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", ">= 2.11"
  spec.add_runtime_dependency "docile"
  spec.add_runtime_dependency "str2hash", ">= 0.1.1"
  spec.add_runtime_dependency "to_regexp"
 
  end
  