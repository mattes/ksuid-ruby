module KSUID
  module ActiveRecord
    module ConnectionAdapters
      module SQLite3AdapterExtension
        def initialize_type_map(m = type_map)
          register_class_with_limit m, %r(ksuid)i, ::KSUID::ActiveRecord::Type
          super
        end
      end

      module PostgreSQLAdapterExtension
        def initialize_type_map(m = type_map)
          register_class_with_limit m, "ksuid", ::KSUID::ActiveRecord::Type
          super
        end
      end
    end
  end
end

if defined?(ActiveRecord::ConnectionAdapters::SQLite3Adapter)
  ActiveRecord::ConnectionAdapters::SQLite3Adapter.prepend(KSUID::ActiveRecord::ConnectionAdapters::SQLite3AdapterExtension)
  ActiveRecord::ConnectionAdapters::SQLite3Adapter::NATIVE_DATABASE_TYPES[:ksuid] = { name: "ksuid" }
end

if defined?(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter)
  ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.prepend(KSUID::ActiveRecord::ConnectionAdapters::PostgreSQLAdapterExtension)
  ActiveRecord::ConnectionAdapters::PostgreSQLAdapter::NATIVE_DATABASE_TYPES[:ksuid] = { name: "ksuid" }
end
