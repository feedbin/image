class ProcessImage
  include Sidekiq::Worker
  sidekiq_options queue: "image_serial_#{Socket.gethostname}", retry: false

  def perform(public_id, image_path, image_url, all_urls)
    image = Image.new(path, target_width: 542, target_height: 304)
    if image.valid?
      path = image.smart_crop!
      UploadImage.perform_async(public_id, path, image_url)
    else
      FindImageCritical.perform_async(public_id, urls)
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

