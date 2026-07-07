source "https://rubygems.org"

gem "rails", "~> 8.1.3"

# Web server
gem "puma", ">= 5.0"

# Database
group :development, :test do
  gem "sqlite3", ">= 2.1"

  gem "debug", platforms: %i[mri windows], require: "debug/prelude"
  gem "bundler-audit", require: false
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
end

group :production do
  gem "pg"
end

# Rails
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"

# Authentication & Admin
gem "devise"
gem "activeadmin"
gem "bcrypt", "~> 3.1.7"
gem "jwt"

# AWS
gem "aws-sdk-s3", require: false

# CORS
gem "rack-cors"

# Assets
gem "propshaft"
gem "sprockets-rails"
gem "sassc-rails"

# Timezone
gem "tzinfo-data", platforms: %i[windows jruby]

# Solid Queue / Cache / Cable
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

# Environment variables
gem "dotenv-rails"

# Performance
gem "bootsnap", require: false

# Deployment
gem "kamal", require: false
gem "thruster", require: false

# Active Storage
gem "image_processing", "~> 1.2"

group :development do
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end