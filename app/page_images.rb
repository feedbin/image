class PageImages
  def initialize(url)
    @url = url
  end

  def self.find_urls(url)
    new(url).find_urls
  end

  def find_urls
    file = Down.download(@url, max_size: 5 * 1024 * 1024)
  rescue Down::Error => exception
    Sidekiq.logger.info "PageImages: exception=#{exception.inspect} url=#{@url}"
    []
  end
end