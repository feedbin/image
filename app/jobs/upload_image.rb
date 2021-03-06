class UploadImage
  include Sidekiq::Worker
  include Helpers
  sidekiq_options queue: "image_parallel_#{Socket.gethostname}", retry: false

  def perform(public_id, image_path, image_url)
    url = upload(image_path, public_id)

  end
end