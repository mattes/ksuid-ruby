# WTF ... this is pretty bad. Monkey patching:
# https://github.com/rails/rails/blob/v6.0.2.1/activerecord/lib/active_record/connection_adapters/abstract/quoting.rb#L235

module ActiveRecord
  module ConnectionAdapters
    module Quoting
      def _type_cast(value)
        case value
        when Symbol, ActiveSupport::Multibyte::Chars, Type::Binary::Data
          value.to_s
        when true then unquoted_true
        when false then unquoted_false
          # BigDecimals need to be put in a non-normalized form and quoted.
        when BigDecimal then value.to_s("F")
        when nil, Numeric, String then value
        when Type::Time::Value then quoted_time(value)
        when Date, Time then quoted_date(value)
        when ::KSUID::Type then value.to_s # TODO added KSUID type handling
        else raise TypeError
        end
      end
    end
  end
end
