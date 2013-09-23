require_relative "../active_record_mocks"

class ActiveSupport::TestCase
  include ActiveRecordMocks::IncludeMe
end
