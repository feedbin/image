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
    if !cache.urls.empty?
      cache.urls
    else
      download if needs_download?
    end
  end

  def download
    file = Down.download(parsed_url, max_size: 5 * 1024 * 1024)
    urls = Nokogiri.HTML5(file.read).search("meta[property='twitter:image'], meta[property='og:image']").map do |element|
      url = element["content"]&.strip
      next if url.nil?
      next if url == ""
      Addressable::URI.join(parsed_url, url)
    end.compact
    cache.save_urls(urls)
    urls
  rescue Down::Error => exception
    Sidekiq.logger.info "PageImages: exception=#{exception.inspect} url=#{@url}"
    []
  end

  def needs_download?
    !cache.page_checked? || cache.site_has_meta?
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