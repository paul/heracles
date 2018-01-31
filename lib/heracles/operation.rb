# frozen_string_literal: true

module Heracles
  class Operation < Shield

    property :name,        Hydra::String, :private
    property :title,       Hydra::String
    property :http_method, Hydra::HTTPMethod, key: "method"
    property :returns,     Hydra::Schema, :remove_null
    property :expects,     Hydra::Schema, :remove_null

    def hydra_type
      ["hydra:Operation", action_name]
    end

    private

    def action_name
      Hydra::Schema[name.to_s + "Action"]
    end

  end
end
