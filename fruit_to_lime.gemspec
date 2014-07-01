# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
    s.name        = 'fruit_to_lime'
    s.version     = '2.6.0'
    s.platform    = Gem::Platform::RUBY
    s.authors     = ['Oskar Gewalli', 'Peter Wilhelmsson', 'Anders Pålsson', 'Ahmad Game']
    s.email       = 'support@lundalogik.se'
    s.summary     = 'Library to generate Lime Go xml import format'
    s.description = <<-EOF
  With this small library it should be much easier to generate import file to Lime Go.
EOF

    s.add_dependency 'iso_country_codes'
    s.add_dependency 'bundler'
    s.add_dependency 'thor'
    s.add_dependency 'roo'
    s.add_dependency 'sixarm_ruby_email_address_validation'
    s.add_dependency 'global_phone'

    # Actually only used by a test_files
    s.add_dependency 'nokogiri'

    s.add_development_dependency 'rspec', '>= 2.14'
    s.add_development_dependency 'rake'

    s.files         = Dir.glob('lib/**/*.rb') + Dir.glob('bin/**/*') +
        Dir.glob('templates/**/*') + Dir.glob('lib/fruit_to_lime/global_phone.json')
    s.test_files    = Dir.glob('spec/**/*.rb')
    s.executables   = ['fruit_to_lime']
    s.require_paths = ['lib']
end
