class Download::Vimeo < Download
  def self.supported_urls
    [
      %r{.*?//vimeo\.com/video/(.*?)(#|\?|$)},
      %r{.*?//vimeo\.com/(.*?)(#|\?|$)},
      %r{.*?//player\.vimeo\.com/video/(.*?)(#|\?|$)},
    ]
  end

  def download
    thumbnail_url = data.dig("thumbnail_url").gsub(/_\d+.jpg/, ".jpg")
    download_file(thumbnail_url)
  rescue Down::Error => exception
  end

  private

  OEMBED_URL = "https://vimeo.com/api/oembed.json"

  def data
    @data ||= begin
      options = {
        params: {
          url: "https://vimeo.com/#{provider_identifier}"
        }
      }
      JSON.load(HTTP.get(OEMBED_URL, options).to_s)
    end
  end
end

