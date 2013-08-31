module BasicLoadTest

  class Stats < Monitor

    attr_reader :cps, :average

    def initialize
      @calls      = 0
      @min_time   = 99999999999.9
      @max_time   = 0.0
      @total_time = 0.0
      @prev_total_time = 0.0
      @prev_calls = 0
      @prev_time_micro = Time.now
      @cps        = 0
      @average    = 0.0
      super
    end

    def increment_calls(time_ms = nil)
      synchronize do
        @calls += 1
        if time_ms
          log_runtime(time_ms, time_ms, time_ms)
        end
      end
    end

    def increment_many_calls(number, total_ms = nil, min_ms = nil, max_ms = nil)
      synchronize do
        @calls += number
        if total_ms
          log_runtime(total_ms, min_ms, max_ms)
        end
      end
    end

    def snapshot
      last_total_time = 0
      last_calls      = 0
      last_time       = 0
      synchronize do
        last_total_time  = @prev_total_time
        @prev_total_time = @total_time
        last_calls  = @prev_calls
        @prev_calls = @calls
        last_time   = @prev_time_micro
        @prev_time_micro = Time.now
      end
      @cps = ((@prev_calls - last_calls) / (@prev_time_micro.to_f - last_time.to_f)).round(3)
      if @prev_calls > 0
        @average = ((@prev_total_time - last_total_time)/(@prev_calls - last_calls)/1000).round(4)
      end
    end

    def print_stats
      print "calls: #{@prev_calls.to_s.ljust(10, ' ')}"
      print "cps: #{@cps.to_s.ljust(10, ' ')} "
      print "min: #{(@min_time/1000).round(4).to_s.ljust(10, ' ')} "
      print "max: #{(@max_time/1000).round(4).to_s.ljust(10, ' ')} "
      if @prev_calls > 0
        print "avg: #{@average.to_s.ljust(10, ' ')} "
      else
        print "avg: na"
      end
      print "\n"
    end

    private

    def log_runtime(total_ms, min_ms, max_ms)
      if min_ms < @min_time
        @min_time = min_ms
      end
      if max_ms > @max_time
        @max_time = max_ms
      end
      @total_time += total_ms
    end

  end
end
