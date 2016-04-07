class AthenaRateLimiter
  def initialize( per_second_rate_limit = 5, per_day_rate_limit = 50000, athena_api_key)
    @per_day_rate_limit = per_day_rate_limit
    @per_second_rate_limit = per_second_rate_limit
    @api_key = athena_api_key
  end

  def should_rate_limit?
    day_rate_limit? || second_rate_limit?
  end

  def day_rate_limit?
    count, _ = $redis.multi do
      $redis.incr(day_key)
      $redis.expireat(day_key, @next_day)
    end
    count >= @per_day_rate_limit
  end

  def second_rate_limit?
    count, _ = $redis.multi do
      $redis.incr(second_key)
      $redis.expire(key, 1)
    end
    count >= @per_second_rate_limit
  end

  private

  def day_key
    if Time.now.to_i <=  $redis.get('expire_at').to_i
      "day_rate_limit:#{@api_key}:#{$redis.get('expire_at')}"
    else
       @next_day = (Time.now + 1.day).to_i
      "day_rate_limit:#{@api_key}:#{@next_day.to_s}"
    end
  end

  def second_key
    time_pattern = Time.now.strftime("%Y-%m-%d-%H-%M-%S")
    "second_rate_limit:#{@api_key}:#{time_pattern}"
  end
end
