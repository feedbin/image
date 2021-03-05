require "minitest/autorun"
require "webmock/minitest"

unless ENV["CI"]
  ENV["REDIS_URL"] = "redis://localhost:7775"
  redis_test_instance = IO.popen("redis-server --port 7775 --save "" --appendonly no")

  Minitest.after_run do
    Process.kill("INT", redis_test_instance.pid)
  end
end

require "sidekiq/testing"
Sidekiq::Testing.fake!
Sidekiq.logger.level = Logger::WARN

require_relative "../app/boot"

def flush
  Sidekiq::Worker.clear_all
  Sidekiq.redis do |redis|
    redis.flushdb
  end
end

def stub_request_file(file, url, options = {})
  file = File.join("test/support/www", file)
  defaults = {body: File.new(file), status: 200}
  stub_request(:get, url)
    .to_return(defaults.merge(options))
end
