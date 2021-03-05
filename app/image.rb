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

# require "benchmark"
# require "shellwords"
# require "open3"
# require "json"
# require "image_processing/vips"
#
# WIDTH = 542
# HEIGHT = 304
#
# def target_dimensions(width, height)
#   target_width = WIDTH.to_f
#
#   width_proportion = width.to_f / height.to_f
#   height_proportion = height.to_f / width.to_f
#
#   target_height = target_width * height_proportion
#
#   if target_height < HEIGHT
#     target_height = HEIGHT.to_f
#     target_width = target_height * width_proportion
#   end
#
#   [target_width.to_i, target_height.to_i]
# end
#
#
# def size(source_path)
#   image = Vips::Image.new_from_file(source_path)
#   resized_width, resized_height =  target_dimensions(image.width, image.height)
#
#   processed_image = ImageProcessing::Vips
#     .source(source_path)
#     .resize_to_fill(resized_width, resized_height)
#     .convert("jpg")
#     .saver(interlace: true, strip: true, quality: 70)
#
#   temporary_image = processed_image.call
#
#   y = 0
#   x = 0
#   smart_crop = false
#
#   if resized_width == WIDTH && resized_height == HEIGHT
#     image = temporary_image
#   elsif resized_width > WIDTH
#     if center = attention_center("x", temporary_image)
#       x = center - WIDTH / 2
#       x = 0 if x < 0
#     else
#       smart_crop = true
#     end
#   else
#     if center = attention_center("y", temporary_image)
#       y = center - HEIGHT / 2
#       y = 0 if y < 0
#     else
#       smart_crop = true
#     end
#   end
#
#   if smart_crop
#     image = processed_image.resize_to_fill!(WIDTH, HEIGHT, crop: :attention)
#   else
#     image = processed_image.crop!(x.to_i, y.to_i, WIDTH, HEIGHT)
#   end
#
#  image
# end
#
# def attention_center(dimension, file)
#   params = {
#     pigo: Shellwords.escape(PIGO),
#     image: Shellwords.escape(file.path),
#     cascade: Shellwords.escape(CASCADE)
#   }
#   command = "%<pigo>s -in %<image>s -out empty -cf %<cascade>s -scale 1.2 -json -"
#   out, _, status = Open3.capture3(command % params)
#
#   if status.success?
#     faces = JSON.load(out)
#   else
#     faces = nil
#   end
#
#   return nil if faces.nil?
#
#   result = faces.flat_map {|face| face.dig("face")}.map do |face|
#     face[dimension] + face["size"] / 2
#   end
#
#   result.sum(0.0) / result.size
# end
