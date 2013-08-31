$:.unshift File.expand_path(File.join(File.dirname(__FILE__), "lib"))

require 'basic_Load_Test'

class TestMe < BasicLoadTest::Benchmark
end


attrs = Hash.new

test = BasicLoadTest::Base.new
test.add_test_class(TestMe, 10, attrs, {}) #{ :fixed_threads => 2 })
test.run
test.print_results_forever(5)

