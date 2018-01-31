# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Rendering links" do
  let(:object) { OpenStruct.new(id: 1, user: user) }
  let(:user)   { OpenStruct.new(id: 2, name: "Paul") }

  subject(:output) { shield.new(object).render }

  describe "regular links" do
    context "when no hydra_id is provided" do
      let(:shield) do
        Class.new(Heracles::Resource) do
          link :user, UserShield
        end
      end

      it "should use the shield's hydra_id" do
        expect(output["user"]).to eq("/User/2")
      end
    end

    context "when a hydra_id is provided" do
      let(:shield) do
        Class.new(Heracles::Resource) do
          link :user, UserShield do |shield|
            shield.merge hydra_id: "/parent/#{id}/special-user/#{user.id}"
          end

          property :id, Heracles::Shield::Hydra::Int, :private
        end
      end

      it "should use the provided hydra_id" do
        expect(output["user"]).to eq("/parent/1/special-user/2")
      end
    end
  end

  describe "full link objects" do
    let(:shield) do
      Class.new(Heracles::Shield) do
        link :user, UserShield, :full
      end
    end

    it "should be a complete link resource" do
      expect(output["user"]).to eq(
        "@id" => "/User/2",
        "@type" => "User",
        "title" => UserShield.description
      )
    end

    context "with operations" do
      let(:shield) do
        Class.new(Heracles::Shield) do
          link :user, UserShield, :full, operations: %i[create update]
        end
      end

      it "should include the non-GET operations in the link resource" do
        expect(output["user"]["operation"]).to eq(
          [
            {
              "@type"   => ["hydra:Operation", "schema:CreateAction"],
              "title"   => "Create a new User",
              "method"  => "POST",
              "expects" => "schema:User",
              "returns" => "schema:User"
            },
            {
              "@type"   => ["hydra:Operation", "schema:UpdateAction"],
              "title"   => "Update the User",
              "method"  => "PUT",
              "expects" => "schema:User",
              "returns" => "schema:User"
            }
          ]
        )
      end
    end

    context "with templated links" do
      let(:shield) do
        Class.new(Heracles::Shield) do
          link :user, UserShield, :full, templates: %i[member]
        end
      end

      it "should include the non-GET operations in the link resource" do
        expect(output["user"]["memberTemplate"]).to eq(
          "@type" => "hydra:IriTemplate",
          "template" => "/User/2{?name}",
          "variableRepresentation" => "hydra:BasicRepresentation",
          "mapping" => [
            {
              "@type"    => "hydra:IriTemplateMapping",
              "variable" => "name",
              "property" => "schema:name",
              "required" => false
            }
          ],
          "operation" => [
            {
              "@type"   => ["hydra:Operation", "schema:UpdateAction"],
              "method"  => "PUT",
              "title"   => "Update the User",
              "expects" => "schema:User",
              "returns" => "schema:User"
            }
          ]
        )
      end
    end
  end
end
