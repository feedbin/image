class MetaImagesCache
  def initialize(url)
    @url = url
  end

  def urls
    []
    # @urls ||= begin
    #   Cache.read(urls_cache_key)
    # end
  end

  def site_has_meta?
    true
  end

  def urls_cache_key
    "refresher_http_#{@feed_id}"
  end

end