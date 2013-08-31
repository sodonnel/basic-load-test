module BasicLoadTest
  class Cordinator

    attr_reader :target_cps, :stats, :klass
    attr_accessor :max_threads, :fixed_threads


    def initialize(klass, target_cps=1, attrs={})
      @threads     = []
      @objects     = []
      @target_cps  = target_cps.to_f
      @klass       = klass
      @stats       = Stats.new
      @klass_attrs = attrs
      @max_threads = 15
      @fixed_threads = nil
      @runnable = true
    end

    def target_cps=(val)
      @target_cps = val.to_f
      @objects.each {|o| o.max_cps=(val) }
    end


    def current_cps
      @stats.cps
    end

    def run
      if @fixed_threads
        spawn_all_threads
      else
        spawn_thread
      end
      while(@runnable) do
        sleep 5
        @stats.snapshot
        unless @fixed_threads
          throttle
        end
      end
    end

    def stop
      @runnable = false
      kill_all
    end

    def print_stats
      @stats.print_stats
    end

    private

    def kill_all
      1.upto(@objects.length) do |i|
        kill_one
      end
    end

    def kill_one
      obj    = @objects.pop
      thread = @threads.pop
      obj.stop
      thread.join
   #   adjust_max_cps_in_threads
    end

    def spawn_all_threads
      1.upto(@fixed_threads) do
        add_thread(@target_cps / @fixed_threads)
      end
    end

    def spawn_thread
      # Event thought the target CPS is set to a value, we want
      # to achieve it over more than 1 thread as it gives a smoother
      # load profile.
      if @threads.count <= @max_threads
        add_thread(@target_cps / 2)
      end
    end

    def add_thread(thread_cps)
      obj = @klass.new(@stats, thread_cps, @klass_attrs)
      @objects.push obj
      @threads << Thread.new do
        obj.run
      end
    end

    def throttle
      current_per_thread = current_cps / @threads.length
      optimal_per_thread = 1.0 / @stats.average
      optimal_threads    = (@target_cps / optimal_per_thread).ceil

      # For bigger targets, the error threshold is a smaller value. Not sure
      # this is strictly necessary.
      error_threshold = 0.1
      if @target_cps >= 40
        error_threshold = 0.05
      end

      # If the current throughput is within the error threshold, just check
      # if there are too many threads and do nothing else.
      if (current_cps - @target_cps).abs < @target_cps * error_threshold
        if (@threads.length - optimal_threads > 3)
          kill_one
          rebalance_threads
        end
        return
      end

      # If the current is under the target, then it needs more threads
      if current_cps < @target_cps
        spawn_thread
        rebalance_threads
        return
      end

      # if at or over the cps limit, and its over it by more than requests per
      # thread, then we can kill a thread, and then rebalance
      if (current_cps - @target_cps > current_per_thread * 1.075) or (@threads.length - optimal_threads > 3)
        kill_one
        rebalance_threads
      end
    end

    def rebalance_threads
      target_per_thread = (@target_cps / @threads.length) * 1.04

      @objects.each do |o|
        o.max_cps = target_per_thread
      end
    end

  end
end
