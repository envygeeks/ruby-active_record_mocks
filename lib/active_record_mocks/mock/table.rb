require "active_support/core_ext/string/inflections"

module ActiveRecordMocks
  class Mock
    class Table
      attr_reader :model_methods
      attr_reader :args

      def initialize(*args, &block)
        @model_methods = []
        @table_name = nil
        @includes = []
        @args = args
        @layout = nil
        @model_name = nil
        @parent_class = nil
      end

      # ---------------------------------------------------------------
      # Tells us if we have already setup this model and object so
      # that we don't keep setting stuff up.
      # ---------------------------------------------------------------

      def setup?
        @already_setup ? true : false
      end

      # ---------------------------------------------------------------
      # Gives the proper object of the model for you.
      # ---------------------------------------------------------------

      def model
        if setup?
          Object.const_get(@model_name)
        end
      end

      # ---------------------------------------------------------------
      # Allows you to set the files that should be included into the
      # model, you must use t.includes because t.include is already
      # a method on the object you are in.
      # ---------------------------------------------------------------

      def includes(*incs)
        if setup? || incs.size == 0
          @includes
        else
          incs.each do |i|
            unless i.blank?
              @includes.push(i)
            end
          end
        end
      end

      # ---------------------------------------------------------------
      # Allows you to set the layout for the table you are building.
      # ---------------------------------------------------------------

      def layout(&block)
        setup? || ! block_given? ? @layout ||= nil : @layout = block
      end

      # ---------------------------------------------------------------
      # Allows the setting of or setuping up of and returning of the
      # name of the table that is being used for the model.  If
      # you do not customize this then it will be a tabelized name
      # of the model, the same way that normal active_record would do.
      # ---------------------------------------------------------------

      def table_name(tname = nil)
        if setup? || (! tname && @table_name)
          @table_name
        else
          @table_name = \
            tname ? tname : model_name.to_s.tableize
        end
      end

      # ---------------------------------------------------------------
      # Allows for the setting of or setup of and returning of the name
      # of the model being used, this should not be confused with model
      # which returns the actual object.  The model need not match the
      # table and sometimes it won't if you chose to be that way.
      # ---------------------------------------------------------------

      def model_name(mname = nil)
        if setup? || (! mname && @model_name)
          @model_name
        else
          @model_name = mname ? mname : \
            SecureRandom.hex(10).tr("^a-z", "").capitalize
        end
      end

      # ---------------------------------------------------------------
      # Allows the setting of or setup of and returning of the name
      # of the parent class. If this is not customized it will
      # default to ActiveRecord::Base
      # ---------------------------------------------------------------

      def parent_class(cname=nil)
        if setup? || (! cname && @parent_class)
          @parent_class
        else
          @parent_class = cname ? cname.to_s.constantize : \
            ActiveRecord::Base
        end
      end

      def setup_mocking!
        if ! setup?
          setup_table!
          setup_model!
          @already_setup = true
        end
      end

      private
      def setup_table!
        ActiveRecord::Migration.tap do |o|
          o.suppress_messages do
            o.create_table table_name, *args do |t|
              layout.call(t) if layout.is_a?(Proc)
            end
          end
        end
      end

      private
      def setup_model!
        definition = Object.const_defined?(model_name) ? Object.const_get(model_name) :
                       Object.const_set(model_name, Class.new(parent_class))
        definition.table_name = table_name
        setup_includes(definition)
        run_model_methods(definition)
      end

      private
      def setup_includes(obj)
        includes.each do |i|
          obj.send(:include, i)
        end
      end

      private
      def run_model_methods(obj)
        model_methods.each do |m|
          obj.send(m[:method], *m[:args], &m[:block])
        end
      end

      public
      def method_missing(methud, *args, &block)
        model_methods.push({
          :block => block,
          :method => methud,
          :args => args
        })
      end
    end
  end
end
