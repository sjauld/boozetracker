# [Cache]
module Cache
  URI = URI.parse(ENV['REDISCLOUD_URL']).freeze

  # Class mixin
  def redis
    Cache.redis
  end

  # Global, memoized, lazy instance of a redis client
  def self.redis
    @redis_client ||= Redis.new(
      host: URI.host,
      port: URI.port,
      password: URI.password
    )
  end
end
