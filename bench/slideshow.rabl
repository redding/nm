# frozen_string_literal: true

object locals[:view].slideshow => :slideshow
attributes :start_slide
child(:slides, object_root: false, root: :slides) do
  attributes :id, :title, :url, :image, :thumb
end
