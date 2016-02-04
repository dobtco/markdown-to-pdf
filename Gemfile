source 'https://rubygems.org'

ruby File.read('.ruby-version').strip

gem 'sinatra'
gem 'octokit'
gem 'pdfkit'
gem 'dotenv'
gem 'rack-ssl-enforcer'
gem 'foreman'
gem 'sinatra_auth_github'

group :production do
  gem 'wkhtmltopdf-heroku'
end

group :development, :test do
  gem 'wkhtmltopdf-binary-edge'
end

group :test do
  gem 'rake'
  gem 'vcr'
  gem 'shoulda'
  gem 'bundler'
  gem 'webmock'
  gem 'rack-test'
  gem 'rubocop'
end
