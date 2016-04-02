# Nm

Data templating system.  Named for its two main markup methods: "node" and "map".  Designed to template data objects for JSON/BSON/whatever/etc serialization.

## Usage

Template:

```ruby
# in /path/to/views/slideshow.json.nm

node 'slideshow' do
  node 'start_slide', start_slide
  node 'slides' do
    map slides do |slide|
      node 'id',    slide.id
      node 'title', slide.title
      node 'image', slide.image_url
      node 'thumb', slide.thumb_url
      node 'url',   slide.url
    end
  end
end
```

Render:

```ruby
require 'nm'
source = Nm::Source.new('/path/to/views')
source.render('slideshow.json', {
  :start_slide => 1,
  :slides => [ ... ] #=> list of slide objects 1, 2 and 3
})
```

Output:

```ruby
{ "slideshow" => {
    "start_slide" => 1,
    "slides" => [
      { "id"    => "slide-1",
        "title" => "Slide 1",
        "thumb" => "//path/to/slide-1-thumb.jpg",
        "image" => "//path/to/slide-1-image.jpg",
        "url"   => "//path/to/slide-1-url",
      },
      { "id"    => "slide-2",
        "title" => "Slide 2",
        "thumb" => "//path/to/slide-2-thumb.jpg",
        "image" => "//path/to/slide-2-image.jpg",
        "url"   => "//path/to/slide-2-url",
      },
      { "id"    => "slide-3",
        "title" => "Slide 3",
        "thumb" => "//path/to/slide-3-thumb.jpg",
        "image" => "//path/to/slide-3-image.jpg",
        "url"   => "//path/to/slide-3-url",
      }
    ]
  }
}
```

## Notes

### Cache Templates

By default the source doesn't cache template files.  You can configure it to cache templates using the `:cache` option:

```ruby
source = Nm::Source.new('/path/to/views', :cache => true)
```

### Default locals

You can specify a set of default locals to use on all renders for a source using the `:locals` option:

```ruby
source = Nm::Source.new('/path/to/views', :locals => {
  'something' => 'value'
})
```

### Render Format

Rendering templates returns a data object (`::Hash` or `::Array`).  To serialize, bring in your favorite JSON/BSON/whatever serializer and pass the rendered object to it.

### Markup Methods

There are two main markup methods:

* `node`: create a named attribute on a hash object
* `map`: create a list object mapped from a given list

### Partials

**Note**: using partials negatively impacts template rendering performance.

(from example above)

```ruby
# in /path/to/views/slideshow.json.nm

node 'slideshow' do
  node 'start_slide', start_slide
  node 'slides' do
    map slides do |slide|
      partial '_slide.json', :slide => slide
    end
  end
end

# in /path/to/views/_slide.json.nm

node 'id',    slide.id
node 'title', slide.title
node 'image', slide.image_url
node 'thumb', slide.thumb_url
node 'url',   slide.url
```

This will render the same output as above.

### Markup Aliases

If you find you need to use a local named `node` or `map`, the markup methods are aliased as `n`, `_node`, `m`, and `_map` respectively.  Any combination of aliases is valid:

```ruby
node 'slideshow' do
  n 'start_slide', start_slide
  _node 'slides' do
    _map slides do |slide|
      _node 'id',    slide.id
      node  'title', slide.title
      _node 'image', slide.image_url
      node  'thumb', slide.thumb_url
      _node 'url',   slide.url
    end
    m other_slides do |slide|
      node  'id',    slide.id
      _node 'title', slide.title
      node  'image', slide.image_url
      _node 'thumb', slide.thumb_url
      node  'url',   slide.url
    end
  end
end
```

## Installation

Add this line to your application's Gemfile:

    gem 'nm'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install nm

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
