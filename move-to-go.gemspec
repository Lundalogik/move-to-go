# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
    s.name        = 'move-to-go'
    s.version     = '5.4.2'
    s.platform    = Gem::Platform::RUBY
    s.authors     = ['Petter Sandholdt', 'Oskar Gewalli', 'Peter Wilhelmsson', 'Anders Pålsson', 'Ahmad Game', 'Rickard Helldin', 'Mikael Davidsson']
    s.email       = 'support@lime.tech'
    s.summary     = 'Tool to generate Lime Go zip import files'
    s.description = <<-EOF
  move-to-go is an migration tool for Lime Go. It can take virtually any input source and create zip-files that LIME Go likes. 
  move-to-go has some predefined sources that makes will help you migrate your data.
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
        Dir.glob('sources/**/*', File::FNM_DOTMATCH) + Dir.glob('lib/move-to-go/global_phone.json')
    s.test_files    = Dir.glob('spec/**/*.rb')
    s.executables   = ['move-to-go']
    s.require_paths = ['lib']
    s.metadata = {
        "changelog_uri"     => "https://github.com/Lundalogik/move-to-go/blob/master/CHANGELOG.md"
    }
end
