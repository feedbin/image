class FindImage
  include Sidekiq::Worker
  include Helpers
  sidekiq_options queue: "image_parallel", retry: false

  def perform(public_id, urls, entry_url = nil)
    if entry_url
      page_urls = MetaImages.find_urls(entry_url)
      urls = page_urls.concat(urls)
      Sidekiq.logger.info "MetaImages: public_id=#{public_id} count=#{page_urls.length} url=#{entry_url}"
    end

    Sidekiq.logger.info "FindImage: public_id=#{public_id} count=#{urls.length}"

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
end

class FindImageCritical
  include Sidekiq::Worker
  sidekiq_options queue: "image_parallel_critical", retry: false
  def perform(*args)
    FindImage.new.perform(*args)
  end
end

