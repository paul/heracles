require "dry/types"
require "active_support/inflector"
require "active_support/core_ext/object/blank"

module Heracles
  module Types
    include Dry::Types.module

    %i[Array Hash Time Date DateTime Decimal Nil].each do |name|
      const_set name, Types::Json.const_get(name)
    end

    String = Types::String.constructor do |str|
      # Always strip whitespace from strings
      str ? str.to_s.strip.chomp : str
    end

    Slug = String.constructor do |str|
      str ? CGI.escape(str) : str
    end

    Link = Types::String
    IriTemplate = Types::String

    Relation = Types::Definition(ActiveRecord::Relation) if defined?(ActiveRecord)

    Members = Array.constructor do |items|
      if items.is_a?(Enumerable)
        items.map { |item| HydraShield.shield(item) }
      end
    end

    Schema = Types::String.constructor do |str|
      str ? ["schema", ActiveSupport::Inflector.camelize(str, true)].join(":") : str
    end

    HTTPMethod = Types::String.constructor do |str|
      str ? str.to_s.upcase : str
    end

  end
end
