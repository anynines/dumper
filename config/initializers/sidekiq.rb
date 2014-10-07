if $redis_config[:password]
  redis_url = "redis://:#{$redis_config[:password]}@#{$redis_config[:host]}:#{$redis_config[:port]}/0"
else
  redis_url = "redis://#{$redis_config[:host]}:#{$redis_config[:port]}/0"
end

Sidekiq.redis = { url: redis_url, namespace: 'sidekiq' }