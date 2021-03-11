class FindImage
  include Sidekiq::Worker
  include Helpers
  sidekiq_options queue: "image_parallel", retry: false

  def perform(public_id, preset_name, candidate_urls, entry_url = nil)
    @public_id = public_id
    @preset_name = preset_name
    @entry_url = entry_url
    @candidate_urls = combine_urls(candidate_urls)

    while original_url = @candidate_urls.shift
      Sidekiq.logger.info "Candidate: public_id=#{@public_id} original_url=#{original_url}"
      download_cache = DownloadCache.copy(original_url, public_id: @public_id, preset_name: @preset_name)
      if download_cache.copied?
        send_to_feedbin(original_url: original_url, storage_url: download_cache.storage_url)
        Sidekiq.logger.info "Copied image: public_id=#{@public_id} original_url=#{original_url} storage_url=#{download_cache.storage_url}"
        break
      elsif download_cache.download?
        break if download_image(original_url, download_cache)
      else
        Sidekiq.logger.info "Skipping download: public_id=#{@public_id} original_url=#{@original_url}"
      end
    end
  end

  def download_image(original_url, download_cache)
    found = false
    download = Download.download!(original_url, minimum_size: preset.minimum_size)
    if download.valid?
      ProcessImage.perform_async(@public_id, @preset_name, download.persist!, original_url, @candidate_urls)
      found = true
    else
      download_cache.save(false)
      Sidekiq.logger.info "Download invalid: public_id=#{@public_id} original_url=#{@original_url}"
    end
    found
  end

  def combine_urls(candidate_urls)
    return candidate_urls unless @entry_url

    if Download.find_download_provider(@entry_url)
      page_urls = [@entry_url]
      Sidekiq.logger.info "Recognized URL: public_id=#{@public_id} entry_url=#{@entry_url}"
    else
      page_urls = MetaImages.find_urls(@entry_url)
      Sidekiq.logger.info "MetaImages: public_id=#{@public_id} count=#{page_urls&.length} entry_url=#{@entry_url}"
    end
    page_urls ||= []
    page_urls.concat(candidate_urls)
  end
end

class FindImageCritical
  include Sidekiq::Worker
  sidekiq_options queue: "image_parallel_critical", retry: false
  def perform(*args)
    FindImage.new.perform(*args)
  end
end
