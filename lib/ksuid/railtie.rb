# frozen_string_literal: true

module KSUID
  # Enables the usage of KSUID types within ActiveRecord when Rails is loaded
  #
  # @api private
  class Railtie < ::Rails::Railtie
    initializer "ksuid" do
      ActiveSupport.on_load :active_record do
        require "ksuid/activerecord"
        require "ksuid/activerecord/table_definition"
        require "ksuid/activerecord/connection_adapters"
      end

      ActiveSupport.on_load :active_job do
        require "ksuid/activejob/serializer"
      end

      config.after_initialize do
        ::ActiveJob::Serializers.add_serializers KSUID::ActiveJob::Serializer
      end
    end
  end
end
