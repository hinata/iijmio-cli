# -*- coding: utf-8 -*-
lib = ::File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'iijmio/cli/version'

Gem::Specification.new do |spec|
  spec.name          = "iijmio-cli"
  spec.version       = ::Iijmio::CLI::VERSION
  spec.authors       = ["Takahiro INOUE"]
  spec.email         = ["takahiro.inoue@mail.3dcg-arts.net"]

  spec.summary       = %q{CLI tools for iijmio API.}
  spec.description   = %q{CLI tools for iijmio API.}
  spec.homepage      = "https://github.com/hinata/iijmio-cli"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "faraday", "~> 0.9.2"
  spec.add_dependency "phantomjs", "~> 2.1.1.0"
  spec.add_dependency "poltergeist", "~> 1.9.0"
  spec.add_dependency "thor", "~> 0.19.1"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.0"
end
