class Download
  attr_reader :path

  def initialize(url, minimum_size: 20_000)
    @url = url
    @valid = false
    @minimum_size = minimum_size
  end

  def self.download!(url, **args)
    klass = find_download_provider(url) || Download::Default
    instance = klass.new(url, **args)
    instance.download
    instance
  end

  def download_file(url)
    @file = Down.download(url, max_size: 10 * 1024 * 1024)
    @path = @file.path
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
      File.join(Dir.tmpdir, ["image_original_", SecureRandom.hex, File.extname(@file)].join)
    end
  end

  def valid?
    valid = @file && @file.content_type&.start_with?("image")
    valid &&= @file.size >= @minimum_size unless @minimum_size.nil?
    valid
  end

  def provider_identifier
    self.class.recognize_url?(@url)
  end

  def self.recognize_url?(src_url)
    if supported_urls.find { |url| src_url =~ url }
      Regexp.last_match[1]
    else
      false
    end
  end

  def self.find_download_provider(url)
    download_providers.detect { |klass| klass.recognize_url?(url) }
  end

  def self.download_providers
    [
      Download::Youtube,
      Download::Instagram,
      Download::Vimeo
    ]
  end

  def self.supported_urls
    []
  end
end
