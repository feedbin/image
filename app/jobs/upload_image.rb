class UploadImage
  include Sidekiq::Worker
  sidekiq_options queue: "image_parallel_#{Socket.gethostname}", retry: false

  def perform(public_id, image_path, image_url)

  end
end