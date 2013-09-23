require "active_record"

module ActiveRecordMocks
  require_relative "active_record_mocks/mock"

  module IncludeMe
    def mocked_active_record
      Mock.new
    end

    def with_mocked_tables(&block)
      if block_given?
        mocked_active_record.tap do |o|
          block.call(o)
          o.delete_tables
        end
      end
    nil
    end
  end
end
