source "https://rubygems.org"
gemspec

group :development do
  unless ENV["CI"]
    gem "pry"
  end

  gem "rake"

  # ---------------------------------------------------------------------------
  # So we can test a bunch of database platforms.
  # ---------------------------------------------------------------------------

  gem "pg", :platforms => [:mswin, :mingw, :ruby]
  gem "activerecord-jdbcpostgresql-adapter", :platforms => :jruby
  gem "activerecord-jdbcmysql-adapter", :platforms => :jruby
  gem "mysql2", :platforms => [:mswin, :mingw, :ruby]
end
