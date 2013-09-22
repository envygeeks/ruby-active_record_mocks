# Important note

*Over the next few days this gem will be transformed to simply be
`active_record_mocks` so it works with Test::Unit, MiniTest and RSpec.
This gem will be a complete alias of the other one and will still be
published but your work flow might change a bit depending on how I
decide to go about the work flow, this means that you could end up
using it in an entirely different way than before.*

# RSpec Active Record Mocks.

[![Build Status](https://travis-ci.org/envygeeks/rspec-active_record_mocks.png?branch=master)](https://travis-ci.org/envygeeks/rspec-active_record_mocks) [![Coverage Status](https://coveralls.io/repos/envygeeks/rspec-active_record_mocks/badge.png?branch=master)](https://coveralls.io/r/envygeeks/rspec-active_record_mocks) [![Code Climate](https://codeclimate.com/github/envygeeks/rspec-active_record_mocks.png)](https://codeclimate.com/github/envygeeks/rspec-active_record_mocks) [![Dependency Status](https://gemnasium.com/envygeeks/rspec-active_record_mocks.png)](https://gemnasium.com/envygeeks/rspec-active_record_mocks)

ActiveRecord Mocks is designed to aide you in testing your ActiveRecord
concerns by creating random models (or even named models) that are
removed after each test.

## Installing

```ruby
gem "rspec-active_record_mocks"
```

## Using

`RSpec::ActiveRecordMocks` supports `before` with `:all` or `:each`, it
can also be used directly inside the it.  It's designed to try and be a
little bit flexible in how you try to use it.

```ruby

# ----------------------------------------------------------------------------
# One Line Usage.
# ----------------------------------------------------------------------------

describe TestConcern do
  it "should work as expected" do
    expect(mock_active_record_model(:include => TestConcern).test_column).to eq "value"
  end
end
```

```ruby

# ----------------------------------------------------------------------------
# An example using extensions!
# ----------------------------------------------------------------------------

describe TestConcern do
  it "should work with extensions" do
    mock_active_record_model(:extensions => :hstore)
    expect(ActiveRecord::Base.connection.extensions).to include "hstore"
  end
end
```

```ruby

# ----------------------------------------------------------------------------
# Before :all example with :include and a migration.
# Also works with `before :each`
# ----------------------------------------------------------------------------

describe TestConcern do
  before :all do
    @test_model = mock_active_record_model(:include => TestConcern) do
      table.string(:test_column)
    end
  end

  it "should have the concerns method" do
    expect(@test_model.new).to respond_to :test_method
  end
end
```

```ruby

# ----------------------------------------------------------------------------
# Before :all example that does a class_eval to include.
# Also works with `before :each`
# ----------------------------------------------------------------------------

describe TestConcern do
  before :all do
    @model = mock_active_record_model.class_eval do
      include MyActiveRecordConcern
    end
  end

  it "should work" do
    expect(@model.concern_method).to eq "concern_value"
  end
end
```

```ruby

# ----------------------------------------------------------------------------
# Completely random example in a before :all.
# Also works with `before :each`
# ----------------------------------------------------------------------------

describe MyActiveRecordConcern do
  before :all do
    @model = mock_active_record_model do |table|
      table.string(:column)
    end

    @model.class_eval do
      include MyActiveRecordConcern
    end
  end
end
```
