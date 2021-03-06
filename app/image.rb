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
    pipeline = ImageProcessing::Vips
      .source(@file)
      .resize_to_fill(resized.width, resized.height)
      .convert("jpg")
      .saver(interlace: true, strip: true, quality: 80)

    if resized.width == @target_width && resized.height == @target_height
      pipeline.call(destination: persisted_path)
      return persisted_path
    end

    if resized.width > @target_width
      axis = "x"
      contraint = @target_width
      max = resized.width - @target_width
    else
      axis = "y"
      contraint = @target_height
      max = resized.height - @target_height
    end

    if center = average_face_position(axis, pipeline.call)
      point = {"x" => 0, "y" => 0}
      point[axis] = center - contraint / 2

      if point[axis] < 0
        point[axis] = 0
      elsif point[axis] > max
        point[axis] = max
      end

      image = pipeline.crop(point["x"], point["y"], @target_width, @target_height)
    else
      image = pipeline.resize_to_fill(@target_width, @target_height, crop: :attention)
    end

    image.call(destination: persisted_path)
    persisted_path
  end

  def resized
    @resized ||= begin
      resized_width = @target_width.to_f

      width_proportion = width.to_f / height.to_f
      height_proportion = height.to_f / width.to_f

      resized_height = resized_width * height_proportion

      if resized_height < @target_height
        resized_height = @target_height.to_f
        resized_width = resized_height * width_proportion
      end
      OpenStruct.new({width: resized_width.to_i, height: resized_height.to_i})
    end
  end

  def average_face_position(axis, file)
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
      face[axis] + face["size"] / 2
    end

    (result.sum(0.0) / result.size).to_i
  end

  def persisted_path
    @persisted_path ||= begin
      File.join(Dir.tmpdir, [SecureRandom.hex, ".jpg"].join)
    end
  end
end