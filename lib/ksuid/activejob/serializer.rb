# frozen_string_literal: true

module KSUID
  module ActiveJob
    class Serializer < ::ActiveJob::Serializers::ObjectSerializer
      def serialize(argument)
        argument.to_s
      end

      def deserialize(argument)
        KSUID::Type.new(argument)
      end

      private

      def klass
        KSUID::Type
      end
    end
  end
end
