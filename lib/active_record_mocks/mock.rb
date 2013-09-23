require_relative "mock/table"
require "active_record"

module ActiveRecordMocks
  class Mock
    class ExtensionsUnsupported < StandardError
      def initialize
        super "Your database server does not support extensions."
      end
    end

    attr_accessor :tables

    def enable_extension(ext)
      raise_if_extensions_unsupported!
      ActiveRecord::Migration.tap do |o|
        o.suppress_messages do
          o.enable_extension(ext)
        end
      end
    end

    def create_table(*args, &block)
      Table.new(*args).tap do |o|
        if block_given?
          block.call(o)
        end

        o.setup_mocking!
        tables.push(o)
        return o.model
      end
    end

    def initialize
      @tables = [
      ]
    end

    def delete_tables
      tables.each do |t|
        Object.send(:remove_const, t.model_name)
        ActiveRecord::Base.connection.drop_table(t.table_name)
      end
    nil
    end

    private
    def raise_if_extensions_unsupported!
      if ! ActiveRecord::Base.connection.respond_to?(:enable_extension)
        raise ExtensionsUnsupported
      end
    end
  end
end
