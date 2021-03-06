require_relative "test_helper"
class FindImageTest < Minitest::Test
  def setup
    flush
  end

  def test_should_process_an_image
    image_url = "http://example.com/image.jpg"
    page_url = "http://example.com/article"
    urls = [image_url]

    stub_request_file("html.html", page_url)
    stub_request_file("image.jpeg", image_url, headers: {content_type: "image/jpeg"})

    stub_request(:get, "http://example.com/image/og_image.jpg").to_return(status: 404)
    stub_request(:get, "http://example.com/image/twitter_image.jpg").to_return(status: 404)

    stub_request(:put, /.*\.s3\.amazonaws\.com/)

    Sidekiq::Testing.inline! do
      FindImage.perform_async(SecureRandom.hex, urls, page_url)
    end

    assert_requested :get, "http://example.com/image/og_image.jpg"
    assert_requested :get, "http://example.com/image/twitter_image.jpg"
  end
end
