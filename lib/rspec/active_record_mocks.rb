require "active_support/core_ext/string/inflections"
require "active_record"
require "rspec"

module RSpec
  module ActiveRecordMocks
    class ExtensionsUnsupportedError < StandardError
      def initialize
        super "Your adapter does not support PostgreSQL extensions"
      end
    end

    # Allow people to mock ActiveRecord while giving them the flexibility.

    def mock_active_record_model(opts = {}, &block)
      tbl, ext = opts.delete(:name), opts.delete(:extensions)
      tbl = create_active_record_table_for_mocking(tbl, ext, &block)
      Object.const_set(tbl.camelize, Class.new(ActiveRecord::Base)).class_eval do
        include opts.delete(:include) if opts[:include]
        self.table_name = tbl and self
      end
    end

    # Roll through each one of the created tables and destroy them.

    def clean_tables_for_active_record_mocking
      if mocked_active_record_options[:mocked_active_record_tables]
        mocked_active_record_options.delete(:mocked_active_record_tables).each do |tbl|
          ActiveRecord::Base.connection.drop_table(tbl) if active_record_tables.include?(tbl)
          if Object.const_defined?(tbl.camelize)
            Object.send(:remove_const, tbl.camelize)
          end
        end
      end
    end

    # Aliases ActiveRecord::Base.connection.tables to active_record_tables to
    # a geniunely useful method that can be used by anybody doing db testing.

    def active_record_tables
      ActiveRecord::Base.connection.tables
    end

    # Allows us to access options for either the class or the test itself as
    # to allow users to either work on the class or work in the test allowing
    # us to cleanup without affecting the other.

    private
    def mocked_active_record_options
      (example.nil?) ? (@mocked_active_record_options ||= {}) : example.options
    end

    # Creates a temporary table inside of the database using ActiveRecord.

    private
    def create_active_record_table_for_mocking(tbl, ext, &block)
      tbl = (tbl || SecureRandom.hex(30).tr('^a-z', '')).to_s
      setup_active_record_mocking_table(tbl, ext, &block)
      tbl
    end

    # Sets up the table using an ActiveRecord migration.

    private
    def setup_active_record_mocking_table(tbl, ext, &block)
      (mocked_active_record_options[:mocked_active_record_tables] ||= []).push(tbl)
      ActiveRecord::Migration.suppress_messages do
        setup_active_record_mocking_extensions(ext)
        ActiveRecord::Migration.create_table tbl do |obj|
          block.call(obj) if block_given?
        end
      end
    end

    # Sets up the extensions for PostgreSQL.

    private
    def setup_active_record_mocking_extensions(ext)
      ext = [ext].delete_if { |value| value.blank? }.flatten
      if ext.size > 0 && ! ActiveRecord::Base.connection.respond_to?(:enable_extension)
        raise ExtensionsUnsupportedError
      else
        ext.each do |extension|
          ActiveRecord::Migration.enable_extension(extension)
        end
      end
    end
  end
end

RSpec.configure do |config|
  config.include RSpec::ActiveRecordMocks
  [:all, :each].each do |type|
    config.after(type) do
      clean_tables_for_active_record_mocking
    end
  end
end
