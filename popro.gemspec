# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name        = 'popro'
  s.version     = '0.2.2'
  s.date        = '2020-09-16'
  s.summary     = "Po'Pro"
  s.description = "The Poor-Man's Progress Indicator"
  s.authors     = ['MikeSmithEU']
  s.files       = Dir.glob('{bin,lib}/**/*') + %w[CHANGELOG LICENSE README.md]
  s.homepage    = 'https://rubygems.org/gems/popro'
  s.license     = 'MIT'
  s.required_ruby_version = '>= 2.7'
end
