# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
    s.name        = 'go_import'
    s.version     = '3.0.35'
    s.platform    = Gem::Platform::RUBY
    s.authors     = ['Petter Sandholdt', 'Oskar Gewalli', 'Peter Wilhelmsson', 'Anders Pålsson', 'Ahmad Game']
    s.email       = 'support@lundalogik.se'
    s.summary     = 'Tool to generate Lime Go zip import files'
    s.description = <<-EOF
  go-import is an import tool for LIME Go. It can take virtually any input source and create zip-files that LIME Go likes. go-import has some predefined sources that makes will help you migrate your data.
EOF

    s.add_dependency 'iso_country_codes'
    s.add_dependency 'bundler'
    s.add_dependency 'thor'
    s.add_dependency 'roo'
    s.add_dependency 'sixarm_ruby_email_address_validation'
    s.add_dependency 'global_phone'
    s.add_dependency 'rubyzip'
    s.add_dependency 'progress'

    # Actually only used by a test_files
    s.add_dependency 'nokogiri'

    s.add_development_dependency 'rspec', '>= 2.14'
    s.add_development_dependency 'rake'

    s.files         = Dir.glob('lib/**/*.rb') + Dir.glob('bin/**/*') +
        Dir.glob('sources/**/*', File::FNM_DOTMATCH) + Dir.glob('lib/go_import/global_phone.json')
    s.test_files    = Dir.glob('spec/**/*.rb')
    s.executables   = ['go-import']
    s.require_paths = ['lib']
end
