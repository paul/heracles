# frozen_string_literal: true

class UserShield < Heracles::Resource
  description "An author is a Person that wrote a BlogPost"

  property :name, Hydra::String, desc: "The textual content"

  operation :create, method: "POST", desc: "Create a new User"
  operation :update, method: "PUT", desc: "Update the User"

  template :member, operations: %i[update], params: %i[name]
end
