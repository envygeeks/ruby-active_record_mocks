require "active_support/core_ext/string/inflections"
require "active_record"

module RSpec
  module ActiveRecordMocks

    # ------------------------------------------------------------------------
    # Allow people to mock ActiveRecord while giving them the flexibility.
    # ------------------------------------------------------------------------

    def mock_active_record_model(opts = {}, &block)
      tbl, ext = opts.delete(:name), opts.delete(:extensions)
      tbl = create_active_record_table_for_mocking(tbl, ext, &block)
      Object.const_set(tbl.camelize, Class.new(ActiveRecord::Base)).class_eval do
        include opts.delete(:include) if opts[:include]
        self.table_name = tbl and self
      end
    end

    # ------------------------------------------------------------------------
    # Roll through each one of the created tables and destroy them.
    # ------------------------------------------------------------------------

    def clean_tables_for_active_record_mocking
      if mocked_active_record_options[:mocked_active_record_tables]
        mocked_active_record_options.delete(:mocked_active_record_tables).each do |tbl|
          Object.send(:remove_const, tbl.camelize) if defined?(tbl.camelize)
          ActiveRecord::Base.connection.drop_table(tbl)
        end
      end
    end

    private
    def mocked_active_record_options
      (example.nil?) ? (@mocked_active_record_options ||= {}) : example.options
    end

    # ------------------------------------------------------------------------
    # Creates a temporary table inside of the database using ActiveRecord.
    # ------------------------------------------------------------------------

    private
    def create_active_record_table_for_mocking(tbl, ext, &block)
      tbl = (tbl || SecureRandom.hex(30).tr('^a-z', '')).to_s
      setup_active_record_mocking_table(tbl, ext, &block)
      tbl
    end

    # ------------------------------------------------------------------------
    # Sets up the table using an ActiveRecord migration.
    # ------------------------------------------------------------------------

    private
    def setup_active_record_mocking_table(tbl, ext, &block)
      (mocked_active_record_options[:mocked_active_record_tables] ||= []).push(tbl)
      ActiveRecord::Migration.suppress_messages do
        [ext].delete_if { |value| value.blank? }.flatten.each do |extension|
          ActiveRecord::Migration.enable_extension(extension)
        end

        ActiveRecord::Migration.create_table tbl do |obj|
          block.call(obj) if block_given?
        end
      end
    end
  end
end

# ----------------------------------------------------------------------------
# Add ourself to the win list so they can use the methods.
# ----------------------------------------------------------------------------

RSpec.configure do |config|
  config.include RSpec::ActiveRecordMocks
  [:all, :each].each do |type|
    config.after(type) do
      clean_tables_for_active_record_mocking
    end
  end
end
