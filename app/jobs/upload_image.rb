class UploadImage
  include Sidekiq::Worker
  include Helpers
  sidekiq_options queue: "image_parallel_#{Socket.gethostname}", retry: false

  def perform(public_id, image_path, original_url)
    processed_url = upload(image_path, public_id)
    send_to_feedbin(public_id, original_url, processed_url)
    DownloadCache.new(original_url, public_id).save(processed_url)
    Sidekiq.logger.info "UploadImage: public_id=#{public_id} url=#{original_url} processed_url=#{processed_url}"
  end
end