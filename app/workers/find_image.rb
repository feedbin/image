class FindImage
  include Sidekiq::Worker
  sidekiq_options queue: "image_parallel_#{Socket.gethostname}", retry: false

  def perform(public_id, urls, entry_url = nil)
    if entry_url
      page_urls = PageImages.find_urls(entry_url)
      urls = page_urls.concat(urls)
    end

    while url = urls.shift
      download = Download.download!(url)
      if download.valid?
        ProcessImage.perform_async(public_id, download.path, url, urls)
        break
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

