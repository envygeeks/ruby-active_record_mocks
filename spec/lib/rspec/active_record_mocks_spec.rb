require "rspec/helper"

describe RSpec::ActiveRecordMocks do
  it "creates an ActiveRecord Model" do
    expect(mock_active_record_model).to respond_to :table_name
    expect(mock_active_record_model).to respond_to :first
    expect(mock_active_record_model).to respond_to :all
  end

  it "allows for enabling extensions" do

    # ------------------------------------------------------------------------
    # THERE IS A CONDITIONAL JRUBY IS BROKEN CLAUSE HERE!
    # ------------------------------------------------------------------------

    pending "MySQL does not support extensions" if ENV["DB_TYPE"] == "mysql2"
    if RbConfig::CONFIG["ruby_install_name"] == "jruby"
      pending "jRuby JDBC is broken when it comes to extensions"
    end

    # ------------------------------------------------------------------------

    mock_active_record_model(:extensions => :hstore)
    extensions_query = "SELECT extname from pg_extension"
    extensions = ActiveRecord::Base.connection.execute(extensions_query).map do |ext|
      ext["extname"]
    end

    expect(extensions).to include "hstore"
  end

  context "with MySQL or jRuby JDBC" do
    it "raises if enabling extensions" do

      # ----------------------------------------------------------------------
      # THERE IS A CONDITIONAL JRUBY IS BROKEN CLAUSE HERE!
      # ----------------------------------------------------------------------

      unless ENV["DB_TYPE"] == "mysql2" || RbConfig::CONFIG["ruby_install_name"] == "jruby"
        pending "This is a MySQL test."
      end

      # ----------------------------------------------------------------------

      expect_error RSpec::ActiveRecordMocks::ExtensionsUnsupportedError do
        mock_active_record_model(:extensions => :hstore)
      end
    end
  end

  it "allows for custom table names" do
    expect(mock_active_record_model(:name => :foo_bar).table_name).to eq "foo_bar"
  end

  it "allows you define a custom layout" do
    mock_active_record_model(:name => :foo_bar) do |table|
      table.string(:foo_bar)
    end

    expect(defined?(FooBar)).to eq "constant"
    expect(FooBar.columns.map(&:name) - ["id"]).to eq ["foo_bar"]
  end

  it "includes a module it's told to include" do
    module TestClass
      def test
        "it works!"
      end
    end

    expect(mock_active_record_model(:include => TestClass).new).to respond_to :test
    expect(mock_active_record_model(:include => TestClass).new.test).to eq "it works!"
  end

  describe "#clean_tables_for_active_record_mocking" do
    it "destroys the constant and the table" do
      expect(mock_active_record_model(:name => :foo_bar).table_name).to eq "foo_bar"
      expect(defined?(FooBar)).to eq "constant"
      clean_tables_for_active_record_mocking
      expect(defined?(FooBar)).to be_nil
      expect(ActiveRecord::Base.connection.tables).not_to include("foo_bar")
    end
  end
end
