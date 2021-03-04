class MetaImages
  def initialize(url)
    @url = url
  end

  def self.find_urls(url)
    new(url).find_urls
  rescue Addressable::URI::InvalidURIError
    []
  end

  def find_urls
    return cache.urls if !cache.urls.empty?
    download if cache.site_has_meta?
  end

  def download
    file = Down.download(parsed_url, max_size: 5 * 1024 * 1024)
    Nokogiri.HTML5(file.read).search("meta[property='twitter:image'], meta[property='og:image']").map do |element|
      url = element["content"]&.strip
      unless url.nil? || url == ""
        Addressable::URI.join(parsed_url, url)
      end
    end.compact
  rescue Down::Error => exception
    Sidekiq.logger.info "PageImages: exception=#{exception.inspect} url=#{@url}"
    []
  end

  def cache
    @cache ||= MetaImagesCache.new(parsed_url)
  end

  def parsed_url
    @parsed_url ||= begin
      parsed = Addressable::URI.parse(@url)
      raise Addressable::URI::InvalidURIError if parsed.host.nil?
      parsed
    end
  end


end