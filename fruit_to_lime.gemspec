# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name        = 'fruit_to_lime'
  s.version     = '0.9.3'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Oskar Gewalli', 'Peter Wilhelmsson', 'Anders Pålsson']
  s.email       = 'support@lundalogik.se'
  s.summary     = 'Library to generate Lime Go xml import format'
  s.description = <<-EOF
  With this small library it should be much easier to generate import file to Lime Go.
EOF

  s.add_dependency 'iso_country_codes'
  s.add_dependency 'bundler'
  s.add_dependency 'thor'

  s.add_development_dependency 'rspec', '>= 2.14'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'roo'
  s.add_development_dependency 'tiny_tds'

  s.files         = Dir.glob('lib/**/*.rb') + Dir.glob('bin/**/*') + Dir.glob('templates/**/*')
  s.test_files    = Dir.glob('spec/**/*.rb')
  s.executables   = ['fruit_to_lime']
  s.require_paths = ['lib']
end
