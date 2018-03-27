# Heracles

[![Gem Version](https://badge.fury.io/rb/heracles.svg)](http://badge.fury.io/rb/heracles)

<!-- Tocer[start]: Auto-generated, don't remove. -->

## Table of Contents

  - [Features](#features)
  - [Screencasts](#screencasts)
  - [Requirements](#requirements)
  - [Setup](#setup)
  - [Usage](#usage)
  - [Tests](#tests)
  - [Versioning](#versioning)
  - [Code of Conduct](#code-of-conduct)
  - [Contributions](#contributions)
  - [License](#license)
  - [History](#history)
  - [Credits](#credits)

<!-- Tocer[finish]: Auto-generated, don't remove. -->

## Features

# What are Shields?

"Shields" are basically a specialized form of the Presenter, to make generating Hydra-style API responses simple and straightforward. The name is a pun on Hydra from the Marvel universe, S.H.I.E.L.D.

To create a shield, you simply need to declare the attributes or properties you want exposed:

```ruby
class BlogPostShield < ApplicationShield

  property :content, Hydra::String

end
```

This results in an API document that looks like:

```json
{
  "@type": "BlogPost",
  "@id": "/posts/1234",
  "@context": "/contexts/BlogPost.jsonld",
  "content": "Hello, *World*!"
}
```

To render the shield within a controller, you can use the render helper:

```ruby
def show
  @post = BlogPost.find(params[:id])
  render shield: @post
end
```

The renderer will attempt to find a Shield for the object passed in (`BlogPost` becomes `BlogPostShield`), but it might fail if there's not shield defined for the class. You can set one explicitly with:

```ruby
render shield: @post, with: BlogPostShield
```

This is also the standard Rails `#render` method, and supports all the regular options, like `status: 404`, etc...

## More Features

### Description

A Shield and each of its properties can (and should!) have a description. This will be used to generate API documentation.

```ruby
class BlogPostShield < ApplicationShield
  description "A blog post, which has body content and an author, and some comments"

  property :content, Hydra::String, desc: "The textual body content"

end
```

_Note: At some point in the future, I'll either make this required, or add a linter that runs in the spec suite, so go ahead and make sure you add them now._

Oftentimes, these descriptions can get fairly long, and with a long attribute name can quickly get unwieldy. You can take advantage of Ruby's HEREDOC syntax to put it on another line:

```
  property :content, Hydra::String, desc: <<~DESC
    Even though in this case it's very simple, you might also have a long description that wouldn't fit neatly on one line
  DESC
```

_The `<<~` HEREDOC symbol handles the extra indentation and un-indents the resulting string._


### Altering attributes

Sometimes, the attribute name that the API should render and the field in the model don't match up. There's a few ways to handle this.

#### Renaming attribute with `:key`

If all that needs to be done if change the attribute name, the you can provide a `key:` option to the property:

```ruby
property :content, Hydra::String, desc: "The textual body content", key: "text"
```

```json
{
  "@type": "BlogPost",
  "@id": "/posts/1234",
  "@context": "/contexts/BlogPost.jsonld",
  "text": "Hello, *World*!"
}
```

In this case, the object given to the shield initializer or the render helper is expected to have a `content` method, and the resulting JSON in the response will have a `"text"` attribute.

This can also be used to provide attribute keys that would otherwise be invalid Ruby method names. It is how the `:hydra_id` property becomes `"@id"` in the response, for example.

_RFC: What about having the opposite be possible, with an `method:` option? Then the JSON output would have the property name as the key, and the given object would be expected to have a method with the alternate name?_

#### Manipulating values

Sometimes, some other manipulation needs to be performed on the attribute. This can be accomplished by simply defining a method with the right name:

```ruby
class BlogPostShield < ApplicationShield
  description "A blog post, which has body content and an author, and some comments"

  property :content, Hydra::String, desc: "The textual body content"
  property :html_content, Hydra::String, desc: "The HTML representation of the textual body content"

  def html_content
    CommonMarker.render_html(content)
  end

end
```

```json
{
  "@type": "BlogPost",
  "@id": "/posts/1234",
  "@context": "/contexts/BlogPost.jsonld",
  "content": "Hello, *World*!",
  "html_content": "<p>Hello, <em>World</em>!</p>",
}
```

#### Hiding Attributes

It is occasionally helpful to be able to access some attributes on the model object without wanting those exposed to the rendered output. You can use the `:private` flag to set a property in this way. (The base ApplicationShield does this automatically for `id`, that way the URL helpers can render something.)

```
property :id, Hydra::Int, :private
```

### Linking to Other Shields

Rendering links to other shields is done with the `link` method:

```ruby
class BlogPostShield < ApplicationShield
  description "A blog post, which has body content and an author, and some comments"

  property :content, Hydra::String, desc: "The textual body content"
  link :author, UserShield, desc: "The User that wrote the blog post"

end
```

```json
{
  "@type": "BlogPost",
  "@id": "/posts/1234",
  "@context": "/contexts/BlogPost.jsonld",
  "content": "Hello, *World*!",
  "author": "/users/5678"
}
```

#### Overriding URL

The `ApplicationShield` attempts to figure out how to generate a URL for a Shield by abusing `ActiveModel::Name` and the Rails `url_for` helpers. In this case, since the `BlogPost` ActiveRecord Model object has an `id`, and the `BlogPostShield` has a `name` of `BlogPost`, `url_for(self)` will result in `/blog_posts/1234`. However, many times the Shield name doesn't match a known route, or the route is part of a nested resource and cannot be determined from the name alone. In these cases, you can assign the URL as part of the property:

```ruby
class BlogPostShield < ApplicationShield
  description "A blog post, which has body content and an author, and some comments"

  property :content, Hydra::String, desc: "The textual body content"
  link :author, UserShield, desc: "The User that wrote the blog post" do |shield|
    shield.merge hydra_id: blog_post_authors_path(self, user)
  end

end
```

```json
{
  "@type": "BlogPost",
  "@id": "/posts/1234",
  "@context": "/contexts/BlogPost.jsonld",
  "content": "Hello, *World*!",
  "author": "/posts/1234/authors/5678"
}
```

### Embedding Other Shields

To embed the content of another shield as an attribute, you can use `embed`.

```ruby
class BlogPostShield < ApplicationShield
  # ...

  embed :author, AuthorShield

end
```

```json
{
  "@type": "BlogPost",
  "@id": "/posts/1234",
  "@context": "/contexts/BlogPost.jsonld",
  "content": "Hello, *World*!",
  "author": {
    "@type": "User",
    "@id": "/users/5678",
    "@context": "/contexts/User.jsonld",
    "name": "James T. Kirk"
  }
}
```

# How It Works

You can initialize the shield either by passing in a `Hash` with those keys, or an object (likely a Rails ActiveRecord Model) that responds to those methods.

```ruby
shield = BlogPostShield.new(content: "Hello, World!")
# => #<BlogPostShield:0x3ffc4cb10a70>
shield.content
# => "Hello, World!"
shield = BlogPostShield.new(OpenStruct.new(content: "Hello, World!"))
# => #<BlogPostShield:0x2aef2689e384>
shield.content
# => "Hello, World!"
```

You can use `#attributes` (also aliased as `#to_hash`) to get all the attributes and their values. This is not the rendered output, but the raw attributes given to the `#initialize` method.

```ruby
shield.to_hash
# => {:content=>"Hello, World!"}
```

To get a hash of the serializable output, use `#serializable_hash`. The renderer function used by Rails to generate responses from shields is basically `JSON.encode(TheShield.new(object).serializable_hash)`. It goes through all the declared attributes and values just like `#to_hash`, but it also transforms each key and value as specified by the property declaration. In this case, the `hydra_id|type|context` properties (which are declared automatically in the base Shield class) have the key names transformed to `"@id"`, `"@type"` and `"@context"`. This process also camelCases the key names if needed, and performs any type-casting or transform functions provided. See below about "Types" for how this process works.

```ruby
shield.serializable_hash
# => {"@type"=>"BlogPost", "@id"=>"/posts/1234", "@context"=>"/contexts/BlogPost.jsonld", "content"=>"Hello, World!"}
```

## Types

The shields take advantage of the Dry-Types library to transform values and cast them to the correct JSON values. To make development and debugging simpler, there's a few ways to access attributes before and after the Type transform has happened.

Attributes provided to `#initialize` are stored without transform, and stored as instance variables. By default the property defines a reader method with the same name.

```ruby
shield = BlogPostShield.new(content: 1234)
# => #<BlogPostShield:562cf7b1c338 @type="BlogPost" @id="/posts/1234" @context="/contexts/BlogPost.jsonld" id=nil content="1234">
shield.instance_variable_get(:@content)
# => 1234
shield.content
# => 1234
shield.to_hash
# => {:hydra_type=>nil, :hydra_id=>nil, :hydra_context=>nil, :id=>nil, :content=>"Hello, World!"}
```

Additionally, `#to_hash` uses these raw untransformed values. It is because it is used as part of the embedding feature, and by the transform function passed as a block to the `property` method. Shield objects themselves are intended to be idempotent, but you can make copies of them with `#new` (also aliased as `#merge`).

```ruby
shield.new(hydra_id: "/blogs/1234")
# => #<BlogPostShield:562cfa23b3d8 @type="BlogPost" @id="/posts/1234" @context="/contexts/BlogPost.jsonld" id=nil content="1234">
_.hydra_id
# => "/posts/1234"
```

When preparing a value for the serializable hash object, it performs these steps:

 1. `#public_send` the property name to get the value
 2. Run that value through the Type function to get a "cast" value
 3. If a transform block was provided to the property, `instance_exec` that in the scope of the shield, yielding the cast value.

A concrete example:

```ruby
class BlogPostShield < ApplicationShield
  property :content, Hydra::String do |value|
    value + "5"
  end

  def content
    attributes[:content] + 3
  end
end

shield = BlogPostShield.new(content: 1)
shield.attributes[:content] # or simply shield[:content]
# => 1
shield.content
# => 4
shield.serializable_attribute(:content)
# => "45"
shield.serializable_hash
# => {"@type"=>"BlogPost", "@id"=>"/posts/1234", "@context"=>"/contexts/BlogPost.jsonld", "content"=>"45"}
```

You can see that `:content` was initially the integer `1`, the `#content` method added `3` to it (accessed via `attributes`), the `Hydra::String` type cast it to a Ruby String, and then the property transform function appended the string "5" to the final result.  Additionally, each shield is a "type", and it "casts" the given object or hash into an instance of itself.

This feature is how `embed` and `link` allow you to provide extra attributes to the child shield, using values that are known only to the parent.

```ruby
class BlogPostShield < ApplicationShield
  embed :comments, Hydra::Collection do |shield|
    # This block is instance_eval'd within the blog_post shield instance.
    # `shield` is the child shield instance `yield`d into the block.

    shield.merge hydra_id: blog_post_comments_path(id)

    # `id` is the blog_post.id attribute, and this will return a new child
    # shield with hydra_id attribute set to /blog_posts/1234/comments
  end
end
```



## Screencasts

## Requirements

0. [Ruby 2.5.0](https://www.ruby-lang.org)

## Setup

To install, type the following:

    gem install heracles

Add the following to your Gemfile:

    gem "heracles"

## Usage

## Tests

To test, run:

    bundle exec rake

## Versioning

Read [Semantic Versioning](http://semver.org) for details. Briefly, it means:

- Major (X.y.z) - Incremented for any backwards incompatible public API changes.
- Minor (x.Y.z) - Incremented for new, backwards compatible, public API enhancements/fixes.
- Patch (x.y.Z) - Incremented for small, backwards compatible, bug fixes.

## Code of Conduct

Please note that this project is released with a [CODE OF CONDUCT](CODE_OF_CONDUCT.md). By
participating in this project you agree to abide by its terms.

## Contributions

Read [CONTRIBUTING](CONTRIBUTING.md) for details.

## License

Copyright 2018 []().
Read [LICENSE](LICENSE.md) for details.

## History

Read [CHANGES](CHANGES.md) for details.
Built with [Gemsmith](https://github.com/bkuhlmann/gemsmith).

## Credits

Developed by [Paul Sadauskas]() at
[]().
