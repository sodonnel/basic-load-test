module BasicLoadTest
  class Base

    # This is the entry class for BasicLoadTest. See the readme file for a quick getting
    # started introduction.

    Thread.abort_on_exception=true

    # Create a new BasicLoadTest object. Creating the object doesn't do much,
    # so to actually run a load test on an a system, add test classes using
    # the add_test_class method.
    def initialize
      @threads     = []
      @cordinators = []
    end

    # Define the load tests you want to run, by passing the class,
    # and target calls per second. The actual class should be passed
    # to this method, and not an instance of the class. The class passed
    # must sub class SimpleLoadTest::Benchmark and implement the run_operation
    # method which performs the actual work.
    #
    # The class
    #
    # The klass_attrs parameter takes a hash and is passed through
    # to the target class.
    #
    # The test_attrs parameter takes a hash and is used to configure
    # how BasicLoadTest executes the load test. The only keys to have any
    # affect on operations are:
    #
    #  :fixed_threads => 5
    #  :max_threads   => 10
    #
    # :fixed_threads causes BasicLoadTest to execute the test in that number of
    # threads.
    #
    # :max_threads sets a limit on how many threads BasicLoadTest will use when
    # attempting to maintain the target calls per second.
    #
    # @example
    #    load_test.add_test_class(DBCall, 50, {}, { :fixed_threads => 5 })
    #    load_test.add_test_class(DBCall, 50, { :username => 'scott', :password => 'tiger' }, {})
    #
    def add_test_class(klass, target_cps, klass_attrs, test_attrs)
      c = Cordinator.new(klass, target_cps, klass_attrs)
      if test_attrs[:fixed_threads]
        c.fixed_threads = test_attrs[:fixed_threads]
      end
      if test_attrs[:max_threads]
        c.max_threads = test_attrs[:max_threads]
      end
      @cordinators.push c
    end

    # After initializing the class and adding some tests with add_test_class,
    # use the run method to start the tests running. This method spawns a new thread
    # for each test (coordinator) and then returns. In the background, each coordinator
    # with spawn one or more threads to run the tests.
    def run
      @cordinators.each do |c|
        @threads << Thread.new do
          c.run
        end
      end
    end

    # This method enters a loop on the main program thread that prints out the stats
    # from each coordinator running tests. By default it will print the status of each
    # coordinator every 5 seconds.
    def print_results_forever(wait_between_print=5)
      while(1) do
        print_results
        sleep wait_between_print
      end
    end

    # Print the stats from each coordinator once and then return
    def print_results
      @cordinators.each do |c|
        print c.klass.to_s.ljust(25, ' ')
        c.print_stats
      end
    end

  end

end
