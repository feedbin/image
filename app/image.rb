class Image

  attr_reader :path

  def initialize(file, target_width:, target_height:)
    @file = file
    @target_width = target_width
    @target_height = target_height
  end

  def valid?
    source.avg && height >= (@target_height + 2) && width >= (@target_width + 2)
  rescue ::Vips::Error
    false
  end

  def height
    source.height
  end

  def width
    source.width
  end

  def source
    @source ||= Vips::Image.new_from_file(@file)
  end

  def smart_crop!
    resized_width, resized_height = resized_dimensions

    processed_image = ImageProcessing::Vips
      .source(@file)
      .resize_to_fill(resized_width, resized_height)
      .convert("jpg")
      .saver(interlace: true, strip: true, quality: 80)

    temporary_image = processed_image.call

    y = 0
    x = 0
    smart_crop = false

    if resized_width == @target_width && resized_height == @target_height
      image = temporary_image
    elsif resized_width > @target_width
      if center = attention_center("x", temporary_image)
        x = center - @target_width / 2
        x = 0 if x < 0
      else
        smart_crop = true
      end
    else
      if center = attention_center("y", temporary_image)
        y = center - @target_height / 2
        y = 0 if y < 0
      else
        smart_crop = true
      end
    end

    if smart_crop
      image = processed_image.resize_to_fill(@target_width, @target_height, crop: :attention)
    else
      image = processed_image.crop(x.to_i, y.to_i, @target_width, @target_height)
    end

    image.call(destination: persisted_path)
    persisted_path
  end

  def resized_dimensions
    resized_width = @target_width.to_f

    width_proportion = width.to_f / height.to_f
    height_proportion = height.to_f / width.to_f

    resized_height = resized_width * height_proportion

    if resized_height < @target_height
      resized_height = @target_height.to_f
      resized_width = resized_height * width_proportion
    end

    [resized_width.to_i, resized_height.to_i]
  end

  def attention_center(dimension, file)
    params = {
      pigo: Shellwords.escape(PIGO),
      image: Shellwords.escape(file.path),
      cascade: Shellwords.escape(CASCADE)
    }
    command = "%<pigo>s -in %<image>s -out empty -cf %<cascade>s -scale 1.2 -json -"
    out, _, status = Open3.capture3(command % params)

    if status.success?
      faces = JSON.load(out)
    else
      faces = nil
    end

    return nil if faces.nil?

    result = faces.flat_map {|face| face.dig("face")}.map do |face|
      face[dimension] + face["size"] / 2
    end

    result.sum(0.0) / result.size
  end

  def persisted_path
    @persisted_path ||= begin
      File.join(Dir.tmpdir, [SecureRandom.hex, ".jpg"].join)
    end
  end
end