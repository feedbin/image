class ImageCache
  include Helpers

  attr_reader :copied_url

  def initialize(url, public_id)
    @url = url
    @public_id = public_id
    @copied_url = nil
  end

  def self.copy(url, public_id)
    instance = new(url, public_id)
    instance.copy
    instance
  end

  def copy
    @copied_url = copy_image(processed_url) unless processed_url.nil?
  end

  def copied?
    !!@copied_url
  end

  def processed_url
    cache[:processed_url]
  end

  def download?
    !previously_attempted?
  end

  def previously_attempted?
    !cache.empty?
  end

  def save(url)
    @cache = {processed_url: url}
    Cache.write(cache_key, @cache, options: {expires_in: 24 * 60 * 60 * 30})
  end

  def cache
    @cache ||= begin
      Cache.read(cache_key)
    end
  end

  def cache_key
    "image_processed_#{Digest::SHA1.hexdigest(@url)}"
  end
end