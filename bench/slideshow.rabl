object locals[:view].slideshow => :slideshow
attributes :start_slide
child(:slides, :object_root => false, :root => :slides){
  attributes :id, :title, :url, :image, :thumb
}
