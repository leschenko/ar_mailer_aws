# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ar_mailer_aws/version'

Gem::Specification.new do |spec|
  spec.name          = 'ar_mailer_aws'
  spec.version       = ArMailerAWS::VERSION
  spec.authors       = ['Alex Leschenko']
  spec.email         = %w(leschenko.al@gmail.com)
  spec.description   = %q{Daemon for sending butches of emails via Amazon Simple Email Service (Amazon SES) using ActiveRecord for storing messages}
  spec.summary       = %q{Send butches of emails via Amazon SES}
  spec.homepage       = 'https://github.com/leschenko/ar_mailer_aws'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = %w(lib)

  spec.add_dependency 'daemons', '~> 1.1.9'
  spec.add_dependency 'aws-sdk', '~> 1.0'
  spec.add_dependency 'activesupport', '>= 3.0'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'forgery'
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'activerecord', '>= 3.0'
end
