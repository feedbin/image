class ProcessImage
  include Sidekiq::Worker
  include Helpers
  sidekiq_options queue: "image_serial_#{Socket.gethostname}", retry: false

  def perform(public_id, preset_name, image_path, original_url, candidate_urls)
    @preset_name = preset_name
    Sidekiq.logger.info "ProcessImage: public_id=#{public_id} original_url=#{original_url}"
    image = Image.new(image_path, target_width: preset.width, target_height: preset.height)
    if image.valid?
      path = image.send(preset.crop)
      UploadImage.perform_async(public_id, @preset_name, path, original_url)
    else
      File.unlink(image_path) rescue Errno::ENOENT
      FindImageCritical.perform_async(public_id, @preset_name, candidate_urls)
    end
  end
end

class ProcessImageCritical
  include Sidekiq::Worker
  sidekiq_options queue: "image_serial_critical_#{Socket.gethostname}", retry: false
  def perform(*args)
    ProcessImage.new.perform(*args)
  end
end
