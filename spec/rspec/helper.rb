ENV["DBHOST"] ||= "localhost"
ENV["DBNAME"] ||= "active_record_mocks_testing"
ENV["DBTYPE"] ||= "postgresql"
ENV["DBUSER"] ||= "jordon"

db_drop_cmd = "'DROP DATABASE IF EXISTS %s;' >/dev/null 2>&1"
db_cmd = ENV["DBTYPE"] == "mysql2" ? "mysql -u %s -e" : "psql -U %s -c"
db_create_cmd = "'CREATE DATABASE %s;' >/dev/null 2>&1"

if RbConfig::CONFIG["ruby_install_name"] == "jruby"
  ENV["DBTYPE"] = ENV["DBTYPE"] ==
    "mysql2" ? "jdbcmysql" : "jdbcpostgresql"
end

require_relative "../support/simplecov"
require "luna/rspec/formatters/checks"
require "active_record_mocks/rspec"
require "rspec/expect_error"
require "pry" unless ENV["CI"]

ActiveRecord::Base.establish_connection(
  :username => ENV["DBUSER"],
  :password => ENV["DBPASSWORD"],
  :database => ENV["DBNAME"],
  :host     => ENV["DBHOST"],
  :adapter  => ENV["DBTYPE"]
)

Dir[File.expand_path("../../support/**/*.rb", __FILE__)].each do |f|
  require f
end

RSpec.configure do |c|
  c.before :suite do
    system db_cmd % ENV["DBUSER"] + db_drop_cmd   % ENV["DBNAME"]
    system db_cmd % ENV["DBUSER"] + db_create_cmd % ENV["DBNAME"]
  end

  c.after :suite do
    ActiveRecord::Base.connection.disconnect!
    system db_cmd % ENV["DBUSER"] + db_drop_cmd % ENV["DBNAME"]
  end
end
