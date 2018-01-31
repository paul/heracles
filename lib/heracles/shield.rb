# frozen_string_literal: true

require "dry/core/class_attributes"
require "dry/core/constants"

require "active_support/core_ext/object/blank"

require "heracles/types"

require "awesome_print"

module Heracles
  class Shield
    extend Dry::Core::ClassAttributes
    include Dry::Core::Constants
    extend Forwardable

    defines :description
    defines :schema
    schema EMPTY_HASH

    Hydra = Heracles::Types

    @meta = EMPTY_HASH

    def self.inherited(klass)
      super
      base = self

      klass.class_eval do
        @meta = base.meta
      end
    end

    def self.meta(meta = Undefined)
      if meta.equal?(Undefined)
        @meta
      else
        Class.new(self) { @meta = @meta.merge(meta) unless meta.empty? }
      end
    end

    def self.call(attributes = EMPTY_HASH)
      return attributes if attributes.is_a?(self)
      new(attributes)
    end
    singleton_class.public_send :alias_method, :[], :call

    def self.property(name, type, *flags, **metadata, &getter)
      ivar = "@#{name}"
      flags_hash = flags.map { |flag| [flag, true] }.to_h
      metadata = {expose: true, name: name, ivar: ivar, getter: getter}.merge(flags_hash).merge(metadata)
      add_attributes(name => type.meta(metadata))
    end

    def self.embed(name, type, *flags, **metadata, &getter)
      property(name, type, *flags, **metadata, &getter)
    end

    def self.link(name, type, *flags, **metadata, &getter)
      metadata[:shield] = type
      metadata[:operations] ||= []
      metadata[:templates] ||= []
      link_type = Class.new(Heracles::Link) do
        # Replace the existing property's type with the more specific shield
        property :shield, type, :private
        # binding.pry
        metadata[:templates].each do |template_name|
          property template_name, Heracles::Template, key: "#{template_name}_template"
        end
      end
      property(name, link_type, *flags, **metadata, &getter)
    end

    def new(new_attributes = EMPTY_HASH)
      self.class.new(attributes.merge(hash_from_object(new_attributes)))
    end
    alias_method :merge, :new

    def initialize(attributes = EMPTY_HASH)
      hash_from_object(attributes).each do |key, val|
        instance_variable_set("@#{key}", val) if self.class.schema.key?(key)
      end
    end

    def hash_from_object(object)
      if object.respond_to?(:to_hash)
        object.to_hash
      else
        self.class.schema.each_key.with_object({}) do |key, hsh|
          hsh[key] = object.public_send(key) if object.respond_to?(key)
        end
      end
    end

    def attributes
      self.class.schema.each_key.with_object({}) do |key, hsh|
        hsh[key] = instance_variable_get(:"@#{key}")
      end
    end
    alias_method :to_hash, :attributes
    alias_method :to_h, :to_hash

    def render
      self.class.schema.each_with_object({}) do |(key, type), hsh|
        next if type.meta[:private]
        name = ActiveSupport::Inflector.camelize(type.meta[:key] || key.to_s, false)
        value = public_send(key)
        value = type[value]

        getter = type.meta[:getter]
        value = instance_exec(value, &getter) if getter

        value = value.render if value.is_a?(Heracles::Shield)

        next if type.meta[:remove_null] && value.blank?
        hsh[name] = value
      end
    end

    def self.add_attributes(new_schema)
      schema schema.merge(new_schema)
      new_schema.each_key do |key|
        attr_reader key unless instance_methods.include?(key)
      end
    end

    def [](name)
      type = self.class.schema[name]

      value = public_send(name)
      value = type[value]

      getter = type.meta[:getter]
      value = instance_exec(value, &getter) if getter

      value
    end

    def inspect
      klass = self.class
      attrs = klass.schema.map { |key, type| " #{type.meta[:key] || key}=#{self[key].inspect}" }.join
      "#<#{klass.name}:#{"%x" % (object_id << 1)}#{attrs}>"
    end
    alias_method :to_s, :inspect

    property :hydra_type, (Hydra::Array | Hydra::String).meta(key: "@type")

    def self.hydra_type
      @hydra_type ||= name.gsub(/Shield$/, "")
    end

    def hydra_type
      self.class.hydra_type
    end

    def self.name
      @name ||= (super || ancestors[1..-1].find(&:name).name)
    end
  end
end
