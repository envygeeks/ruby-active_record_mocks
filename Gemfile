source "https://rubygems.org"
gemspec

group :development do
  unless ENV["CI"]
    gem "pry"
  end

  gem "activerecord-jdbcpostgresql-adapter", :platforms => :jruby
  gem "activerecord-jdbcmysql-adapter", :platforms => :jruby
  gem "mysql2", :platforms => [:mswin, :mingw, :ruby]
  gem "pg", :platforms => [:mswin, :mingw, :ruby]
  gem "rake"
  gem "envygeeks-coveralls"
  gem "luna-rspec-formatters"
end
