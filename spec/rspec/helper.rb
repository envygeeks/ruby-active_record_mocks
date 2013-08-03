db_cmd = ENV["DB_TYPE"] == "mysql2" ? "mysql -u %s -e" : "psql -U %s -c"
db_database = "rspec_active_record_mocker_testing"
db_user = ENV["DB_USER"] || "jordon"

if RbConfig::CONFIG["ruby_install_name"] == "jruby"
  ENV["DB_TYPE"] = ENV["DB_TYPE"] == "mysql2" ? "jdbcmysql" : "jdbcpostgresql"
end

require "luna/rspec/formatters/checks"
require "rspec/expect_error"
require_relative "../support/simplecov"
require "rspec/active_record_mocks"

# ----------------------------------------------------------------------------
# Base connection.
# ----------------------------------------------------------------------------

ActiveRecord::Base.establish_connection(
  :password => ENV["DB_PASSWORD"],
  :database => db_database,
  :username => db_user,
  :host     => "localhost",
  :adapter  => ENV["DB_TYPE"] || "postgresql"
)

Dir[File.expand_path("../../support/**/*.rb", __FILE__)].each do |f|
  require f
end

RSpec.configure do |config|
  config.before :suite do
    system("#{db_cmd % db_user} 'DROP DATABASE IF EXISTS #{db_database}' >/dev/null 2>&1")
    system("#{db_cmd % db_user} 'CREATE DATABASE #{db_database}' >/dev/null 2>&1")
  end

  config.after :suite do
    ActiveRecord::Base.connection.disconnect!
    system("#{db_cmd % db_user} 'DROP DATABASE IF EXISTS #{db_database}' >/dev/null 2>&1")
  end
end
