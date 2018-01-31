require_relative "user_shield"

class BlogPostShield < Heracles::Resource
  description "A BlogPost has content and an author and comments"

  property :content, Hydra::String, desc: "The textual content"

  embed :author, UserShield

  link :comments, Heracles::CollectionShield do |shield|
    shield.merge(hydra_id: hydra_id + "/comments")
  end

  property :id, Hydra::Int, :private
  property :user, Hydra::Any, :private
  alias_method :author, :user

  def hydra_id
    "/blog_posts/#{id}"
  end
end

