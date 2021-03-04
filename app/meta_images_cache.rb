class MetaImagesCache
  def initialize(url)
    @url = url
  end

  def urls
    @urls ||= begin
      Cache.read_list(urls_cache_key)
    end
  end

  def save_urls(urls)
    Cache.write_list(urls_cache_key, urls)
  end

  def site_has_meta?
    true
  end

  def page_checked?

  end

  def cached
    @cached ||= begin
      Cache.read(cache_key)
    end
  end

  def cache_key
    "refresher_http_#{@feed_id}"
  end

  def urls_cache_key
    "refresher_http_#{@feed_id}"
  end

end