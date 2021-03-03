class UploadImage
  include Sidekiq::Worker
  sidekiq_options queue: :images, retry: false

  def perform(public_id, image_path, image_url, all_urls)
    image = Image.attention_resize!(path, width: 542, height: 304)
    if image.valid?
      UploadImage.perform_async(public_id, image.path, image_url)
    else
      FindImage.perform_async(public_id, urls)
    end
  end
end