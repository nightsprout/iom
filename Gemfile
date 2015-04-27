source 'http://rubygems.org'
ruby '1.9.3'

gem 'rails', '~> 3.1'

# PostgreSQL
gem 'pg'
gem 'nofxx-georuby',           :require => 'geo_ruby'
gem 'rgeo'
gem 'rgeo-geojson'
gem 'activerecord-postgis-adapter'
gem 'puma'

gem 'annotate'

gem 'redis-rails'
gem 'resque', "~> 1.25"

gem 'newrelic_rpm'
gem 'will_paginate', '~> 3.0'
gem 'sanitize', '~> 3.0.2'
gem 'paperclip', '~> 2.7'
gem 'aws-sdk'
gem 'garb'
gem 'csv-mapper'
gem 'fastercsv'
gem 'money'
gem 'geokit'
gem 'nokogiri', '~> 1.6.3.1'
gem 'memcachier'
gem 'dalli'
gem 'spreadsheet'
gem 'roadie'
gem 'ruby-oembed'
gem 'sass'
gem 'compass'
gem 'wkhtmltopdf-binary'
gem 'wicked_pdf'
gem 'browser'
gem 'heroku-api'
#gem 'rd_searchlogic', :require => 'searchlogic', :git => 'git://github.com/railsdog/searchlogic.git'

group :development do
  gem 'git-up'
  gem 'capistrano'
  gem 'rvm-capistrano', require: false
  gem 'capistrano-ext'
  gem 'wirble'
  gem 'railroady'
  gem 'dotenv'
#  gem 'mail_view', :git => 'https://github.com/37signals/mail_view.git'
end

group :test, :development do
  gem 'rr', :tag => 'v1.0.0'
  gem "rspec-rails"
  gem 'launchy'
  gem 'capybara', '~> 2.2.0'
  gem 'webrat'
  gem 'database_cleaner', :tag => 'v0.5.2'
  gem 'steak'
  gem 'selenium-webdriver'
end