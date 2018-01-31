# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Rendering simple shields" do
  include RSpec::ResemblesJsonMatchers

  let(:post) { OpenStruct.new(id: 1, content: "Hello, world!", user: OpenStruct.new(id: 2, name: "Paul")) }
  let(:shield) { BlogPostShield.new(post) }

  subject(:output) { shield.render }

  it "should look like a Hydra/JSON+LD document" do
    expect(output).to resemble_json(
      "@id":      eq("/blog_posts/1"),
      "@type":    eq("BlogPost"),
      "@context": eq("/contexts/BlogPost.jsonld"),
      "content":  eq("Hello, world!"),
      "author":   {
        "@id":      eq("/User/2"),
        "@type":    eq("User"),
        "@context": eq("/contexts/User.jsonld"),
        "name":     eq("Paul")
      },
      "comments": eq("/blog_posts/1/comments")
    )
  end
end
