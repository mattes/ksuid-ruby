# frozen_string_literal: true

require "ksuid/activerecord/binary_type"
require "ksuid/activerecord/type"

module KSUID
  module ActiveRecordExtension
    extend ActiveSupport::Concern

    included do

      # after_initialize initializes a model's primary key with a new KSUID
      after_initialize do |obj|
        return if !obj.respond_to?(:new_record?) || !obj.class.respond_to?(:type_for_attribute)

        pk = obj.class.primary_key
        if obj.new_record? && obj.class.type_for_attribute(pk).type.to_sym == :ksuid
          obj.write_attribute(pk, KSUID.new) if obj.read_attribute(pk).blank?
        end
      end
    end

    class_methods do
      def act_as_ksuids(*fields)
        fields.each do |f|
          self.act_as_ksuid(f.to_sym)
        end
      end

      def act_as_ksuid(field = :id, opts = {})
        if opts[:binary]
          self.send(:attribute, field.to_sym, :ksuid_binary)
        else
          self.send(:attribute, field.to_sym, :ksuid)
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, KSUID::ActiveRecordExtension)
