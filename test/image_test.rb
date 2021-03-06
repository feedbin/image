require_relative "test_helper"
class ImageTest < Minitest::Test

  def test_should_get_image_size
    file = File.expand_path("support/www/image.jpeg", __dir__)
    image = Image.new(file, target_width: 542, target_height: 304)
    assert_equal(image.width, 640)
    assert_equal(image.height, 828)
    assert_equal([542, 701], image.resized_dimensions)
  end

  def test_should_get_face_location
    file = File.expand_path("support/www/image.jpeg", __dir__)
    image = Image.new(file, target_width: 542, target_height: 304)

    assert_equal(455.6, image.attention_center("y", File.new(file)))
  end

  def test_should_crop
    file = File.expand_path("support/www/image.jpeg", __dir__)
    image = Image.new(file, target_width: 542, target_height: 304)
    cropped_path = image.smart_crop!
    assert cropped_path.include?(".jpg")

    pp Digest::SHA1.hexdigest(File.read(cropped_path))
    FileUtils.rm cropped_path
  end
end
