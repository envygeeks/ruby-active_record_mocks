db_cmd = ENV["DB_TYPE"] == "mysql2" ? "mysql -u %s -e" : "psql -U %s -c"
db_drop_cmd = "'DROP DATABASE IF EXISTS %s' >/dev/null 2>&1"
db_create_cmd = "'CREATE DATABASE %s' >/dev/null 2>&1"
db_database = "active_record_mocks_testing"
db_user = ENV["DB_USER"] || "jordon"

if RbConfig::CONFIG["ruby_install_name"] == "jruby"
  ENV["DB_TYPE"] = ENV["DB_TYPE"] ==
    "mysql2" ? "jdbcmysql" : "jdbcpostgresql"
end

require_relative "../support/simplecov"
require "luna/rspec/formatters/checks"
require "active_record_mocks/rspec"
require "rspec/expect_error"
require "pry" unless ENV["CI"]

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
    system db_cmd % db_user + db_drop_cmd % db_database
    system db_cmd % db_user + db_create_cmd % db_database
  end

  config.after :suite do
    ActiveRecord::Base.connection.disconnect!
    system db_cmd % db_user + db_drop_cmd % db_database
  end
end
