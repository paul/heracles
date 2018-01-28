# frozen_string_literal: true

module Heracles
  # Gem identity information.
  module Identity
    def self.name
      "heracles"
    end

    def self.label
      "Heracles"
    end

    def self.version
      "0.1.0"
    end

    def self.version_label
      "#{label} #{version}"
    end
  end
end
