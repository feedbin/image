require_relative "test_helper"
class ImageCacheTest < Minitest::Test
  def setup
    flush
  end

  def test_should_save_url
    image_url = "http://example.com/example/example.jpg"
    processed_url = "http://s3.com/example/example.jpg"
    public_id = SecureRandom.hex

    cache = ImageCache.new(image_url, public_id)
    cache.save(processed_url)

    cache = ImageCache.new(image_url, public_id)
    assert_equal(processed_url, cache.processed_url)
  end

  def test_should_copy_existing_image
    image_url = "http://example.com/example/example.jpg"
    processed_url = "http://s3.com/example/example.jpg"
    public_id = SecureRandom.hex

    body = <<~EOT
    <?xml version="1.0" encoding="UTF-8"?>
    <CopyObjectResult>
       <ETag>string</ETag>
       <LastModified>Tue, 02 Mar 2021 12:58:45 GMT</LastModified>
    </CopyObjectResult>
    EOT

    stub_request(:put, /.*\.s3\.amazonaws\.com/).to_return(status: 200, body: body)

    cache = ImageCache.new(image_url, public_id)
    refute cache.copied?

    cache.save(processed_url)
    cache.copy

    assert cache.copied?
    assert cache.copied_url.include?(public_id)
  end

  def test_should_fail_to_copy_missing_image
    image_url = "http://example.com/example/example.jpg"
    processed_url = "http://s3.com/example/example.jpg"
    public_id = SecureRandom.hex
    s3_host = /.*\.s3\.amazonaws\.com/

    stub_request(:put, s3_host).to_return(status: 404)

    cache = ImageCache.new(image_url, public_id)
    cache.save(processed_url)
    cache.copy
    refute cache.copied?
    assert_requested :put, s3_host
  end
end
