class Download::Default < Download
  def self.recognize_url?(*args)
    true
  end

  def download
    download_file(@url)
  rescue Down::Error => exception
  end
end