class FindImage
  include Sidekiq::Worker
  sidekiq_options queue: "image_parallel_#{Socket.gethostname}", retry: false

  def perform(public_id, urls, entry_url = nil)
    if entry_url
      page_urls = MetaImages.find_urls(entry_url)
      urls = page_urls.concat(urls)
    end

    while url = urls.shift
      download_cache = DownloadCache.copy(url, public_id)
      if download_cache.copied?
        raise "todo: send back to feedbin"
        break
      elsif download_cache.download?
        download = Download.download!(url, public_id)
        if download.valid?
          ProcessImage.perform_async(public_id, download.persist!, url, urls)
          break
        end
      end
    end
  end
end

class FindImageCritical
  include Sidekiq::Worker
  sidekiq_options queue: "image_parallel_critical_#{Socket.gethostname}", retry: false
  def perform(*args)
    FeedParser.new.perform(*args)
  end
end

