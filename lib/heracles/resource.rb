# frozen_string_literal: true

module Heracles
  class Resource < Shield

    defines :operations, :templates
    operations({})
    templates({})

    property :id, Hydra::Int, :private

    property :hydra_id,      Hydra::String.meta(key: "@id")
    property :hydra_context, Hydra::String.meta(key: "@context")

    def self.operation(name, desc:, method: "GET", returns: hydra_type, expects: hydra_type)
      operations[name] = Heracles::Operation.new(name: name, http_method: method, title: desc, returns: returns, expects: expects)
    end

    def self.template(name, operations: [], params: [])
      templates[name] = Heracles::Template.new(name: name, operations: operations, params: params)
    end

    def hydra_id
      "/#{hydra_type}/#{id}"
    end

    def hydra_context
      @hydra_context ||= "/contexts/#{hydra_type}.jsonld"
    end
  end
end
