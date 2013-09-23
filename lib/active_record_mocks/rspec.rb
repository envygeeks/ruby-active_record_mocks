require_relative "../active_record_mocks"
require "rspec"

RSpec.configure do |config|
  config.include ActiveRecordMocks::IncludeMe
end
