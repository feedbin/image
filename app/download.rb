class Download

  attr_reader :path

  def initialize(url, minimum_size: 20_000)
    @url = url
    @valid = false
    @minimum_size = minimum_size
  end

  def self.download!(url, **args)
    instance = new(url, **args)
    instance.download
    instance
  end

  def download
    @file = Down.download(@url, max_size: 10 * 1024 * 1024)
    @path = @file.path
  rescue Down::Error => exception
    Sidekiq.logger.info "Download failed: exception=#{exception.inspect} url=#{@url}"
  end

  def persist!
    unless @path == persisted_path
      FileUtils.cp @path, persisted_path
      @path = persisted_path
    end
    persisted_path
  end

  def persisted_path
    @persisted_path ||= begin
      File.join(Dir.tmpdir, [SecureRandom.hex, File.extname(@file)].join)
    end
  end

  def valid?
    valid = @file && @file.content_type&.start_with?("image")
    valid = valid && @file.size >= @minimum_size unless @minimum_size.nil?
    valid
  end
end