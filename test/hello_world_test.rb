require 'minitest/autorun'

class HelloWorldTest < Minitest::Test
  def test_hello_world
    assert_equal 'Hello, World!', 'Hello, World!'
  end
end