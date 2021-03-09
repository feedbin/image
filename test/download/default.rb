require_relative "../test_helper"
class Download::DefaultTest < Minitest::Test
  def test_should_download_valid_image
    url = "http://example.com/image.jpg"
    stub_request(:get, url).to_return(headers: {content_type: "image/jpg"}, body: "12345678")
    download = Download.download!(url, minimum_size: 8)
    assert_instance_of Download::Default, download
  end
end
