# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'yard/mdx/version'

Gem::Specification.new do |spec|
  spec.name          = "yard-mdx"
  spec.version       = YARD::MDX::VERSION
  spec.authors       = ["Pieter van de Bruggen"]
  spec.email         = ["pvande@gmail.com"]

  spec.summary       = %q{An MDX template for YARD documentation, suitable for https://docs.page.}
  spec.description   = %q{An MDX template for YARD documentation, suitable for https://docs.page.}
  spec.homepage      = "https://github.com/pvande/yard-mdx"
  spec.license       = "MIT"

  spec.files         = Dir['lib/**/*'] + %w(Gemfile LICENSE.text README.md Rakefile yard-mdx.gemspec)
  spec.require_paths = ["lib"]

  spec.add_dependency "yard", "~> 0.9.0"

  spec.add_development_dependency "bundler", "~> 2.5"
  spec.add_development_dependency "rake", "~> 13.0"
end
