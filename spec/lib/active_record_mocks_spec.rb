require "rspec/helper"

describe ActiveRecordMocks do
  subject(:ar_connection) do
    ActiveRecord::Base.connection
  end

  it "simply skips if somebody passes no blocks" do
    expect(with_mocked_tables).to be_nil
  end

  it "allows you to create a table" do
    with_mocked_tables do |m|
      t1 = m.create_table
      t2 = m.create_table
      expect(ar_connection.tables).to include t1.table_name
      expect(ar_connection.tables).to include t2.table_name
    end
  end

  it "removes tables after the closure" do
    with_mocked_tables do |m|
      m.create_table
      m.create_table
    end

    expect(ar_connection.tables).to be_empty
  end

  it "removes constants after the closure" do
    with_mocked_tables do |m|
      m.create_table do |t|
        t.model_name "Foo"
      end
    end

    expect(defined?(Foo)).to be_nil
  end

  it "enables extensions" do
    expect(ActiveRecord::Migration).to receive(:enable_extension).with("foo")
    allow(ActiveRecordMocks::Mock).to \
      receive(:raise_if_extensions_unsupported).and_return false

    with_mocked_tables do |m|
      m.enable_extension "foo"
    end
  end

  it "raises if extensions are unsupported" do
    allow(ar_connection).to receive(:respond_to?).and_return nil
    expect { with_mocked_tables { |m| m.enable_extension "foo" }
      }.to raise_error ActiveRecordMocks::Mock::ExtensionsUnsupported
  end

  it "supports changing the model name" do
    with_mocked_tables do |m|
      t1 = m.create_table do |t|
        t.model_name "Foo"
      end

      expect(defined?(Foo)).to be_truthy
      expect(t1.table_name).to eq "Foo".tableize
    end
  end

  it "supports changing the table name" do
    with_mocked_tables do |m|
      t1 = m.create_table do |t|
        t.table_name "foo"
      end

      expect(t1.table_name).to eq "foo"
      expect(ar_connection.tables).to include "foo"
    end
  end

  it "supports changing the table and the model name" do
    with_mocked_tables do |m|
      t1 = m.create_table do |t|
        t.model_name "Foo"
        t.table_name "bar"
      end

      expect(defined?(Foo)).to be_truthy
      expect(t1.table_name).to eq "bar"
      expect(ar_connection.tables).to include "bar"
    end
  end

  it "supports table layouts" do
    with_mocked_tables do |m|
      t1 = m.create_table do |t|
        t.layout do |l|
          l.text :foo
        end
      end

      expect(t1.columns.map(&:name)).to include "foo"
    end
  end

  it "supports including modules" do
    Object.const_set(:Foo, Module.new).class_eval do
      def foo
        :bar
      end
    end

    with_mocked_tables do |m|
      t1 = m.create_table do |t|
        t.includes Foo
      end

      expect(t1.new.foo).to eq :bar
      expect(t1.new).to respond_to :foo
      Object.send(:remove_const, :Foo)
    end
  end

  it "passes methods it doesn't know to the model" do
    with_mocked_tables do |m|
      t1 = m.create_table do |t|
        t.has_many :bars
        t.model_name :Foo
      end

      t2 = m.create_table do |t|
        t.model_name :Bar
        t.belongs_to :foo
      end

      expect(t2.reflections[:foo]).not_to be_nil
      expect(t1.reflections[:bars]).not_to be_nil
      expect(t1.reflections[:bars].macro).to eq :has_many
      expect(t2.reflections[:foo].macro).to eq :belongs_to
    end
  end
end
