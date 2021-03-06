module Helpers
  def copy_image(url, public_id)
    url = URI.parse(url)
    source_object_name = url.path[1..-1]
    S3_POOL.with do |connection|
      connection.copy_object(ENV['AWS_S3_BUCKET'], source_object_name, ENV['AWS_S3_BUCKET'], image_name(public_id), options)
    end
    final_url = url.path = "/#{image_name(public_id)}"
    url.to_s
  rescue Excon::Error::NotFound
    false
  end

  def upload(path, public_id)
    S3_POOL.with do |connection|
      File.open(path) do |file|
        response = connection.put_object(ENV['AWS_S3_BUCKET'], image_name(public_id), file, options)
        URI::HTTPS.build(
          host: response.data[:host],
          path: response.data[:path]
        ).to_s
      end
    end
  end

  def image_name(public_id)
    File.join(public_id[0..6], "#{public_id}.jpg")
  end

  def options
    {
      "Cache-Control" => "max-age=315360000, public",
      "Expires" => "Sun, 29 Jun 2036 17:48:34 GMT",
      "x-amz-storage-class" => ENV["AWS_S3_STORAGE_CLASS"] || "REDUCED_REDUNDANCY",
      "x-amz-acl" => "public-read"
    }
  end

end
