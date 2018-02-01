# frozen_string_literal: true

require "spec_helper"

RSpec.describe Heracles::CollectionShield do
  let(:shield) do
    Class.new(Heracles::Resource) do
      property :posts, Heracles::CollectionShield.of(BlogPostShield) do |shield|
        shield.merge(hydra_id: hydra_id + "/posts")
      end

      def hydra_id
        "/blog"
      end
    end
  end

  let(:post) { OpenStruct.new(id: 1, content: "Hello, world!", user: OpenStruct.new(id: 2, name: "Paul")) }
  let(:object) do
    OpenStruct.new(id: 1, posts: [post])
  end

  subject(:output) { shield.new(object).render }

  it "should render the members of the collection" do
    expect(output["posts"]).to eq(
      "@id"      => "/blog/posts",
      "@type"    => "hydra:Collection",
      "@context" => "/contexts/hydra:Collection.jsonld",
      "members" => [
        {
          "@type"    => "BlogPost",
          "@id"      => "/blog_posts/1",
          "@context" => "/contexts/BlogPost.jsonld",
          "content"  => "Hello, world!",
          "author"   => {
            "@type"    => "User",
            "@id"      => "/User/2",
            "@context" => "/contexts/User.jsonld",
            "name"     => "Paul"
          },
          "comments" => "/blog_posts/1/comments"
        }
      ]
    )
  end
end
