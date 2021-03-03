require_relative "test_helper"
class PageImagesTest < Minitest::Test
  def test_should_download_file
    url = "http://example.com/"
    stub_request_file("html.html", url)
    urls = PageImages.find_urls(url)
  end
end
