# Active Record Mocks.

[![Build Status](https://travis-ci.org/envygeeks/ruby-active_record_mocks.png?branch=master)](https://travis-ci.org/envygeeks/ruby-active_record_mocks) [![Coverage Status](https://coveralls.io/repos/envygeeks/ruby-active_record_mocks/badge.png?branch=master)](https://coveralls.io/r/envygeeks/ruby-active_record_mocks) [![Code Climate](https://codeclimate.com/github/envygeeks/ruby-active_record_mocks.png)](https://codeclimate.com/github/envygeeks/ruby-active_record_mocks) [![Dependency Status](https://gemnasium.com/envygeeks/ruby-active_record_mocks.png)](https://gemnasium.com/envygeeks/ruby-active_record_mocks)

ActiveRecord Mocks is designed to aide you in testing your ActiveRecord
concerns by creating random models (or even named models) that are
removed after each test.  It was originally concieved to test concerns,
includes and other types of things that normally aren't tied to a
model specifically.

## Installing

```ruby
gem "active_record_mocks"
```

## Using

```ruby
with_mocked_tables do |m|
  m.enable_extension "uuid-ossp"
  m.enable_extension "hstore"

  t1 = m.create_table do |t|
    t.model_name :Foo
    t.belongs_to :bar

    t.layout do |l|
       l.integer :bar_id
    end
  end

  t2 = m.create_table do |t|
    t.model_name :Bar
    t.has_many   :foo

    t.layout do |l|
      l.text :bar_text
    end
  end

  # Do Work Here
end
```

---

### Extensions

You can enable PostgreSQL extensions inside of your models using the
`enable_extension` method when inside of `with_mocked_tables` or
`with_mocked_models` like so:

```ruby
with_mocked_tables do |m|
  m.enable_extension "extension-name"
end
```

---

### Creating Tables and Layouts

To create tables you use the `create_table` method when inside of
`with_mocked_tables` or `with_mocked_models`, like so:

```ruby
with_mocked_tables do |m|
  m.create_table migration_arguments do |t|
    t.layout do |l|
      l.text :foo_text
    end
  end
end
```

#### Belongs to, Has Many and other methods

Any method that `ActiveRecordMocks` does not know or understand is
passed on to the model itself, so if you need for example `belongs_to`
then you would simply use belongs to when creating your table:

```ruby
with_mocked_tables do |m|
  m.create_table migration_arguments do |t|
    t.belongs_to :bar_model
    t.layout do |l|
      l.text :foo_text
    end
  end
end
```

#### Named models and tables

If you need a named model or a named table or a model whose table is
different than it's model you can use the methods `model_name` and
`table_name`, if you simply need a named model and you use standard
naming conventions than you can simply leave out the `table_name`
when using model name and `ActiveRecordMocks` will tabelize the name
of your model automatically the same as `Rails` would.

```ruby
with_mocked_tables do |m|
  t1 = m.create_table migration_arguments do |t|
    t.model_name :Foo
    t.layout do |l|
      l.text :foo_text
    end
  end
end

# Results in:
#   - Foo  (Model)
#   - foos (Table)
```

```ruby
with_mocked_tables do |m|
  t1 = m.create_table migration_arguments do |t|
    t.table_name :old_foo
    t.model_name :Foo
    t.layout do |l|
      l.text :foo_text
    end
  end
end

# Results in:
#   - Foo      (Model)
#   - old_foo  (Table)
```

#### Model Includes

If you need to include anything into your model you can use the
`includes` method when inside of `with_mocked_models` or
`with_mocked_tables`, like so:

```ruby
with_mocked_tables do |m|
  m.create_table migration_arguments do |t|
    t.includes Bar1, Bar2
    t.layout do |l|
      l.text :foo_text
    end
  end
end
```

#### Using a custom parent class

If you need to test a base class that is not ActiveRecord::Base,
you can do so by specifying the `parent_class` method.

This is useful if your code base uses a custom base class that
derives from ActiveRecord::Base, like so:

```ruby

class MyBase < ActiveRecord::Base
  self.abstract_class = true
  def a_custom_method
    42
  end
end

with_mocked_tables do |m|
  m.create_table migration_arguments do |t|
    t.parent_class :MyBase
    t.model_name :Foo
    t.layout do |l|
      l.text :foo_text
    end
  end

  f = Foo.new
  f.is_a?(MyBase)   # <= true
  f.a_custom_method # <= 42
end


```
