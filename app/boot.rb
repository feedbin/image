$LOAD_PATH.unshift File.expand_path(File.dirname(File.dirname(__FILE__)))

$stdout.sync = true


require "bundler/setup"
require "dotenv"
Dotenv.load
require "socket"
require "etc"
require "net/http"
require "securerandom"
require "time"
require "uri"
require "etc"

require "addressable"
require "dotenv"
require "fog/aws"
require "http"
require "librato-rack"
require "mime-types"
require "nokogumbo"
require "redis"
require "image_processing"
require "down"
require "sidekiq"

require "lib/constants"
require "lib/down"
require "lib/redis"
require "lib/librato"
require "lib/worker_stat"
require "lib/sidekiq"
require "lib/s3_pool"
require "lib/helpers"

require "app/meta_images"
