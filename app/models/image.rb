class Image

  attr_reader :path

  def initialize(path)
    @path = path
  end

  def self.process!(url)

  end

  def height
    source.height
  end

  def width
    source.width
  end

  def source
    @source ||= Vips::Image.new_from_file(@path)
  end
end