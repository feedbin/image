class FindImage
  include Sidekiq::Worker
  include Helpers
  sidekiq_options queue: "image_parallel", retry: false

  def perform(public_id, urls, entry_url = nil)
    urls = combine_urls(public_id, urls, entry_url) if entry_url

    while url = urls.shift
      Sidekiq.logger.info "Candidate: public_id=#{public_id} url=#{url}"
      download_cache = DownloadCache.copy(url, public_id)
      if download_cache.copied?
        send_to_feedbin(public_id, url, download_cache.copied_url)
        Sidekiq.logger.info "Copied image: public_id=#{public_id} url=#{url} processed_url=#{download_cache.copied_url}"
        break
      elsif download_cache.download?
        download = Download.download!(url)
        if download.valid?
          ProcessImage.perform_async(public_id, download.persist!, url, urls)
          break
        else
          Sidekiq.logger.info "Download invalid: public_id=#{public_id} url=#{url}"
        end
      end
    end
  end

  def combine_urls(public_id, urls, entry_url)
    if Download.find_download_provider(entry_url)
      page_urls = [entry_url]
      Sidekiq.logger.info "Recognized URL: public_id=#{public_id} url=#{entry_url}"
    else
      page_urls = MetaImages.find_urls(entry_url)
      Sidekiq.logger.info "MetaImages: public_id=#{public_id} count=#{page_urls.length} url=#{entry_url}"
    end
    page_urls.concat(urls)
  end
end

class FindImageCritical
  include Sidekiq::Worker
  sidekiq_options queue: "image_parallel_critical", retry: false
  def perform(*args)
    FindImage.new.perform(*args)
  end
end
