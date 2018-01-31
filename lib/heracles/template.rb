module Heracles
  class Template < Shield

    property :mapping,                 Hydra::Array
    property :variable_representation, Hydra::String
    property :template,                Hydra::IriTemplate
    property :operations,              Hydra::Array, :remove_null, key: "operation"

    property :name,   Hydra::String,                  :private
    property :params, Hydra::Array.of(Hydra::String), :private
    property :shield, Heracles::Shield,               :private

    def template
      shield.hydra_id + "{?" + params.join(",") + "}"
    end

    def hydra_type
      "hydra:IriTemplate"
    end

    def variable_representation
      "hydra:BasicRepresentation"
    end

    def operations
      @operations.map do |operation|
        shield.class.operations.fetch(operation).render
      end
    end

    def mapping
      params.map do |param|
        {
          "@type"    => "hydra:IriTemplateMapping",
          "variable" => param.to_s,
          "property" => "schema:#{param}",
          "required" => false
        }
      end
    end
  end
end

