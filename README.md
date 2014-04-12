# Nm

JSON/BSON data structure template system.  Named for its two template methods: "node" and "map".

## Usage

Template:

```ruby
# in views/slideshow.json.nm

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

Output:

```json
{ "slideshow": {
    "start_slide": 1,
    "slides": [
      { "id":    "slide-1",
        "title": "Slide 1",
        "thumb": "//path/to/slide-1-thumb.jpg",
        "image": "//path/to/slide-1-image.jpg",
        "url":   "//path/to/slide-1-url",
      },
      { "id":    "slide-2",
        "title": "Slide 2",
        "thumb": "//path/to/slide-2-thumb.jpg",
        "image": "//path/to/slide-2-image.jpg",
        "url":   "//path/to/slide-2-url",
      },
      { "id":    "slide-3",
        "title": "Slide 3",
        "thumb": "//path/to/slide-3-thumb.jpg",
        "image": "//path/to/slide-3-image.jpg",
        "url":   "//path/to/slide-3-url",
      }
    ]
  }
}
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
