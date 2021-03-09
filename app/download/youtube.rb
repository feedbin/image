class Download::Youtube < Download
  def self.supported_urls
    [
      %r{.*?//www\.youtube-nocookie\.com/embed/(.*?)(\?|$)},
      %r{.*?//www\.youtube\.com/embed/(.*?)(\?|$)},
      %r{.*?//www\.youtube\.com/user/.*?#\w/\w/\w/\w/(.+)\b},
      %r{.*?//www\.youtube\.com/v/(.*?)(#|\?|$)},
      %r{.*?//www\.youtube\.com/watch\?v=(.*?)(&|#|$)},
      %r{.*?//youtube-nocookie\.com/embed/(.*?)(\?|$)},
      %r{.*?//youtube\.com/embed/(.*?)(\?|$)},
      %r{.*?//youtu\.be/(.+)}
    ]
  end

  def download
    download_file("https://i.ytimg.com/vi/#{provider_identifier}/maxresdefault.jpg")
  rescue Down::Error => exception
    download_file("https://i.ytimg.com/vi/#{provider_identifier}/hqdefault.jpg")
  end
end