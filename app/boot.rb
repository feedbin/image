$LOAD_PATH.unshift File.expand_path(File.dirname(File.dirname(__FILE__)))

$stdout.sync = true

OPENCV_CLASSIFIER = File.absolute_path("lib/opencv/haarcascade_frontalface_alt.xml")

require "bundler/setup"
require "dotenv"
Dotenv.load

require "socket"
require "etc"
require "net/http"
require "securerandom"
require "time"
require "uri"

require "addressable"
require "dotenv"
require "fog/aws"
require "http"
require "librato-rack"
require "mime-types"
require "nokogumbo"
require "redis"
require "vips"
require "sidekiq"

require "lib/redis"
require "lib/librato"
require "lib/worker_stat"
require "lib/sidekiq"
require "lib/s3_pool"
require "lib/helpers"
