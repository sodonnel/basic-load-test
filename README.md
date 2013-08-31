# BasicLoadTest

BasicLoadTest is a simple gem that is intended to perform simple load tests. It does this by running coordinators in multiple threads. Each coordinator is assigned a Ruby class to performs a unit of work and a target calls per second. Within the coordinator, multiple threads will be assigned to attempt to meet the number of calls per second requested.

# Use Cases

To perform testing of a webservice, for example, it is probably best to use JMeter. It has many more features and is much more robust than this gem. 

However, if you want to quickly test something that would take some custom coding in JMeter (eg database stored procedure calls with randomized inputs), this gem is useful.

# Limitations

In this version, the code that attempts to meet the target CPS is very beta. For instance, if you request a CPS of 10,000, and the system being tested is not capable of reaching that load, by default BasicLoadTest will keep adding threads in an attempt to reach the target CPS, and it will quickly bog down under the load. With this in mind, it is advisable to always set the max_threads parameter to prevent this from happening.

# Load Test Classes

As mentioned above, each coordinator requires a test class to do the actual load testing. This can be any Ruby class, but it must sub class BasicLoadTest::Bemchmark.

It also must implement the run_operation method which takes no parameters. A simple (and useless) sample class is:

    class TestClass < BasicLoadTest::Benchmark
    
      def run_operation
        sleep 0.5
      end

    end

You can also override the initialize method to do some setup (eg create a database connection, prepare a procedure call etc). Just remember to call super:
    
    class TestClass < BasicLoadTest::Benchmark
    
      def initialize(stats, max_cps, attrs=nil)
        super(stats, max_cps, attrs)
        # @conn = establish_db_connection()    
      end

      def run_operation
        sleep 0.5
      end

      def close_down
        # @conn.disconnect
      end

    end

If the class needs to establish a database connection, it is advisable to also override the close_down method (as shown above). This method is called if the coordinator wants to kill a thread.

# Creating a simple (and useless) load test

    require 'basic_Load_Test'

    class TestMe < BasicLoadTest::Benchmark

      def run_operation
        sleep 0.5
      end

    end
    
    test_attrs = {
      :db_username => 'foo',
      :db_password => 'bar'
    }

    test = BasicLoadTest::Base.new
    test.add_test_class(TestMe, 10, test_attrs, { :fixed_threads => 15 })
    test.run
    test.print_results_forever(5)


You can get as creative as you like inside the test classes, so long as they conform to the interface described above. The key is that the run_operation method makes a single call to the operation to be load tested.

You can also add many test classes by making repeat calls to add_test_class so many tests are running at the same time. This is ideal when you want to test a mixed workload, for example inserting, updating and querying a database to simulate a production workload.

# Reliability

I have used this gem against databases to create a reasonable load, in the order of several 100 CPS. I also created a simple benchmark against Redis, where I was able to sustain a load of about 50,000 CPS.

I found that MRI Ruby did not take me anywhere close to these numbers, and I had to use JRuby instead. I guess this is because of the thread limitations in MRI Ruby, which are fairly well known.

I have never tested this gem against operations which take many seconds to complete.

If the runtime of the operation being testing is highly variable (eg 0.1 seconds - 0.5 seconds), the CPS will vary up and down - the algorthm used to adjust the load is not very advanced.

