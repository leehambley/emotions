require 'rubygems'
require 'bundler'

require 'singleton'
require 'tempfile'

Bundler.setup

require 'daemon_controller'

require 'minitest/unit'
require 'minitest/spec'
require 'minitest/autorun'

require_relative '../lib/emotions'

ExampleObject             = Class.new
ExampleTarget             = Class.new
ExampleUnNamespacedObject = Class.new

module Namespace

  ExampleObject = Class.new

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

  module Test
    
    class Unit
      TestCase = Class.new(MiniTest::Unit::TestCase)
    end

    class Acceptance
      TestCase = Class.new(MiniTest::Unit::TestCase)
    end

    class Integration
      TestCase = Class.new(MiniTest::Unit::TestCase)
    end

  end

  Test::Integration::TestCase.add_setup_hook do
    ::IntegrationTestRedis.start
    rb = RedisBackend.new
    rb.redis = Redis.new(port: 9737)
    rb.redis.flushdb
    Emotions.backend = rb
  end

  Test::Integration::TestCase.add_teardown_hook do
    ::IntegrationTestRedis.stop
  end

end

