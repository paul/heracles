# frozen_string_literal: true

module Heracles
  class Link < Shield
    property :hydra_id,  Hydra::String, key: "@id"
    property :title,     Hydra::String
    property :operation, Hydra::Array, :remove_null

    property :shield, Heracles::Shield, :private

    def initialize(attributes = EMPTY_HASH)
      super(hash_from_object(attributes).tap { |attrs|
        shield = self[:shield].new(attributes)
        attrs[:shield] = shield
        self.class.meta[:templates].each do |template_name|
          template = shield.class.templates[template_name]
          attrs[template_name] = template.new(shield: shield)
        end
      })
    end

    def to_serializable_hash
      return hydra_id unless self.class.meta[:full]
      super
    end

    def operation
      self.class.meta[:operations].map do |operation|
        shield.class.operations.fetch(operation).render
      end
    end

    def hydra_id
      @hydra_id ||= shield.hydra_id
    end

    def hydra_type
      @hydra_type ||= shield.hydra_type
    end

    def title
      @title ||= shield.class.description
    end
  end
end
