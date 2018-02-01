# frozen_string_literal: true

module Heracles
  class CollectionShield < Resource
    def self.of(item_shield)
      meta(item_shield: item_shield)
    end

    def initialize(attributes = EMPTY_ARRAY)
      super(attributes.is_a?(Hash) ? attributes : { members: attributes })
    end

    property :members, Hydra::Members, desc: "The items in the collection" do |members|
      members.map { |item| self.class.meta[:item_shield].new(item).to_serializable_hash }
    end

    def self.name
      "hydra:Collection"
    end
  end
end
