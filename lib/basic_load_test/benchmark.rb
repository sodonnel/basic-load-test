module BasicLoadTest

  class Benchmark

    attr_accessor :max_cps

    def initialize(stats, max_cps, attrs=nil)
      @stats               = stats
      @max_cps             = max_cps
      @sleep               = 0
      @runnable            = true
      @attrs               = attrs
    end

    def run
      begin
        calls           = 0.0
        total_call_time = 0.0
        sleep_per_call  = 0.0
        min_ms          = 9999.9
        max_ms          = 0.0
        interval_start  = Time.now
        while(@runnable) do
          # run the process you want to run, sleep here for demo
          call_start = Time.now
          run_operation
          call_time = (Time.now.to_f - call_start.to_f) * 1000 # ms

          total_call_time += call_time
          calls += 1
          if call_time > max_ms
            max_ms = call_time
          end

          if call_time < min_ms
            min_ms = call_time
          end

          if sleep_per_call > 0
            sleep (sleep_per_call / 1000) # sleep method takes seconds.
          end

          if calls >= @max_cps or total_call_time > 1000
            @stats.increment_many_calls(calls, total_call_time, min_ms, max_ms)
            time_for_all_calls = (Time.now.to_f - interval_start.to_f) * 1000 # ms
            total_sleep_time   = sleep_per_call * calls

            average_time_per_call = (time_for_all_calls - total_sleep_time) / calls

            # 90% fudge factor - thread may not wake up on time? :-/
            sleep_per_call = ((1000.0 / @max_cps) - average_time_per_call) * 0.9
            if sleep_per_call < 0
              sleep_per_call = 0
            end
            if time_for_all_calls < 1000
              sleep ((1000 - time_for_all_calls) / 1000)
            end
            calls           = 0.0
            total_call_time = 0.0
            max_ms          = 0.0
            min_ms          = 9999.9
            interval_start  = Time.now
          end

        end
      rescue Exception => e
        puts "Thread failure: #{e.to_s}"
        raise
      end
      close_down
    end

    def run_operation
      sleep 1
    end

    def stop
      @runnable = false
    end

    def close_down
    end

  end
end
