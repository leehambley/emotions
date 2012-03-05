require 'rubygems'
require 'bundler'

require 'singleton'
require 'tempfile'

Bundler.setup

require 'daemon_controller'

require 'minitest/unit'
require 'minitest/spec'
require 'minitest/autorun'

require 'turn'

require_relative '../lib/emotions'

Turn.config do |tc|
  tc.ansi   = true
  tc.format = :dot
end

IntegrationTestRedis = DaemonController.new(
  identifier:    "Emotions Ingration Test Redis Server",
  start_command: "redis-server #{File.expand_path('./emotions_integration_test_redis.conf', 'test')}",
  ping_command:  [:tcp, '127.0.0.1', 9737],
  pid_file:      "/tmp/emotions_integration_test_redis.pid",
  log_file:      "/tmp/emotions_integration_test_redis.log",
  start_timeout: 2
)

module Emotions

  module MiniTest
    
    class Unit
      TestCase = Class.new(::MiniTest::Unit::TestCase)
    end

    class Acceptance
      TestCase = Class.new(Unit::TestCase)
    end

    class Integration
      TestCase = Class.new(Acceptance::TestCase)
    end

  end

end

Emotions::MiniTest::Unit::TestCase.class_eval do

  def setup_with_clean_objects
    setup_without_clean_objects
    Object.const_set(:ExampleObject, Class.new)
    ::ExampleObject.class_eval { attr_accessor :id }
    Object.const_set(:ExampleTarget, Class.new)
    ::ExampleTarget.class_eval { attr_accessor :id }
  end
  alias :setup_without_clean_objects :setup
  alias :setup :setup_with_clean_objects

  def teardown_with_clean_objects
    teardown_without_clean_objects
    Object.send(:remove_const, :ExampleObject)
    Object.send(:remove_const, :ExampleTarget)
  end
  alias :teardown_without_clean_objects :teardown
  alias :teardown :teardown_with_clean_objects

end

Emotions::MiniTest::Integration::TestCase.class_eval do

  def setup_with_live_redis
    setup_without_live_redis
    ::IntegrationTestRedis.start
    rb = Emotions::RedisBackend.new
    rb.redis = ::Redis.new(port: 9737)
    rb.redis.flushdb
    Emotions.backend = rb
  end
  alias :setup_without_live_redis :setup
  alias :setup :setup_with_live_redis

  def teardown_with_live_redis
    teardown_without_live_redis
    ::IntegrationTestRedis.stop
  end
  alias :teardown_without_live_redis :teardown
  alias :teardown :teardown_with_live_redis

end
