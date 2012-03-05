require 'test_helper'

module Emotions

  class UnitTestKeyBuilder < MiniTest::Unit::TestCase

    def test_an_argument_error_is_raised_when_instantiated_with_an_empty_hash
      assert_raises KeyError do
         KeyBuilder.new({})
      end
    end

    def test_generating_a_simple_key
      example_object = ::ExampleObject.new
      example_object.id = 123
      assert_equal 'example_object:test:123', KeyBuilder.new(object: example_object, emotion: :test).key
    end

    def test_generating_a_key_with_a_non_numerical_id
      example_instance = ::ExampleObject.new
      example_instance.id = "digest"
      assert_equal 'example_object:test:digest', KeyBuilder.new(object: example_instance, emotion: :test).key
    end

    def test_generating_a_key_for_an_object_class_count
      # Note: This slightly abuses the KeyBuilder (target vs. object)
      example_target = ::ExampleTarget.new
      example_target.id = 456
      assert_equal 'example_target:like:456', KeyBuilder.new(object: example_target, emotion: :like).key
    end

    def test_generating_a_key_for_an_object_class
      example_object = ::ExampleObject.new
      example_object.id = 123
      assert_equal 'example_object:like:123:example_target', KeyBuilder.new(object: example_object, emotion: :like, target: ::ExampleTarget).key
    end

    def test_generating_a_key_for_a_simple_emotion
      example_object = ::ExampleObject.new
      example_object.id = 123
      example_target = ::ExampleTarget.new
      example_target.id = 456
      assert_equal 'example_object:like:123:example_target', KeyBuilder.new(object: example_object, emotion: :like, target: example_target).key
    end

    def test_generating_a_key_for_a_less_simple_emotion
      example_object = ::ExampleObject.new
      example_object.id = 123
      example_target = ::ExampleTarget.new
      example_target.id = 456
      assert_equal 'example_object:absolute_hate:123:example_target', KeyBuilder.new(object: example_object, emotion: :absolute_hate, target: example_target).key
    end

  end

end
