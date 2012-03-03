require 'test_helper'

module Emotions

  class UnitTestKeyBuilder < Test::Unit::TestCase

    def test_an_argument_error_is_raised_when_instantiated_with_a_null_object
      assert_raises ArgumentError do
         KeyBuilder.new(nil)
      end
    end

    def test_generating_a_simple_un_namespaced_key
      example_instance = ExampleUnNamespacedObject.new
      example_instance.class.send(:define_method, :id, lambda { 123 })
      assert_equal 'example_un_namespaced_object:123', KeyBuilder.new(example_instance).key
    end

    def test_generating_a_simple_namespaced_key
      example_instance = Namespace::ExampleObject.new
      example_instance.class.send(:define_method, :id, lambda { 123 })
      assert_equal 'namespace:example_object:123', KeyBuilder.new(example_instance).key
    end

    def test_generating_a_key_with_a_non_numerical_id
      example_instance = ::ExampleObject.new
      example_instance.class.send(:define_method, :id, lambda { "digest" })
      assert_equal 'example_object:digest', KeyBuilder.new(example_instance).key
    end

    def test_raising_an_argument_error_when_passing_an_emotion_but_no_target
      assert_raises ArgumentError do
        KeyBuilder.new(true, {emotion: true, target: nil})
      end
    end

    def test_generating_a_key_for_a_simple_emotion
      example_object = ::ExampleObject.new
      example_object.class.send(:define_method, :id, lambda { 123 })
      example_target = ::ExampleTarget.new
      example_target.class.send(:define_method, :id, lambda { 456 })
      assert_equal 'example_object:123:like:example_target:456', KeyBuilder.new(example_object, {emotion: :like, target: example_target}).key
    end

    def test_generating_a_key_for_a_less_simple_emotion
      example_object = ::ExampleObject.new
      example_object.class.send(:define_method, :id, lambda { 123 })
      example_target = ::ExampleTarget.new
      example_target.class.send(:define_method, :id, lambda { 456 })
      assert_equal 'example_object:123:absolute_hate:example_target:456', KeyBuilder.new(example_object, {emotion: :absolute_hate, target: example_target}).key
    end

  end

end
