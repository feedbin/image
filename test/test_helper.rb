require "minitest/autorun"
require "webmock/minitest"

unless ENV["CI"]
  socket = Socket.new(:INET, :STREAM, 0)
  socket.bind(Addrinfo.tcp("127.0.0.1", 0))
  port = socket.local_address.ip_port
  socket.close

  ENV["REDIS_URL"] = "redis://localhost:%d" % port
  redis_test_instance = IO.popen("redis-server --port %d --save '' --appendonly no" % port)

  Minitest.after_run do
    Process.kill("INT", redis_test_instance.pid)
  end
end

require "sidekiq/testing"
Sidekiq::Testing.fake!
Sidekiq.logger.level = Logger::WARN

require_relative "../app/boot"

ENV["AWS_ACCESS_KEY_ID"]     = "AWS_ACCESS_KEY_ID"
ENV["AWS_SECRET_ACCESS_KEY"] = "AWS_SECRET_ACCESS_KEY"
ENV["AWS_S3_BUCKET"]         = "images"

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
