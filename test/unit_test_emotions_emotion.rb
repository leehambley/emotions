require 'test_helper'

module Emotions

  class UnitTestEmotion < MiniTest::Unit::TestCase

    def test_an_argument_error_is_raised_when_instantiated_without_a_target
      assert_raises KeyError do
        Emotion.new(object: true, emotion: true)
      end
    end

    def test_an_argument_error_is_raised_when_instantiated_without_an_object
      assert_raises KeyError do
        Emotion.new(target: true, emotion: true)
      end
    end

    def test_an_argument_error_is_raised_when_instantiated_without_an_emotion
      assert_raises KeyError do
        Emotion.new(object: true, target: true)
      end
    end

    def test_emotions_with_the_same_properties_compare_equal
      o, t = Class.new, Class.new
      emotion_one = Emotion.new(emotion: :test, target: t, object: o)
      emotion_two = Emotion.new(emotion: :test, target: t, object: o)
      assert_equal emotion_one, emotion_two
    end

    def test_emotions_with_different_properties_do_not_compare_equal
      emotion_one = Emotion.new(emotion: :test, target: Class.new, object: Class.new)
      emotion_two = Emotion.new(emotion: :test, target: Class.new, object: Class.new)
      refute_equal emotion_one, emotion_two
    end

    def test_the_creation_time_is_readable_via_an_accessor_default_nil
      assert_nil Emotion.new(object: true, target: :example, emotion: true).created_at
    end

    def test_the_target_is_readable_via_an_accessor
      assert_equal :example, Emotion.new(object: true, target: :example, emotion: true).target
    end

    def test_the_object_is_readable_via_an_accessor
      assert_equal :example, Emotion.new(object: :example, target: true, emotion: true).object
    end

    def test_the_emotion_is_readable_via_an_accessor
      assert_equal :example, Emotion.new(object: true, target: true, emotion: :example).emotion
    end

    def test_the_target_key_is_made_available_via_an_accessor
      example_object = ::ExampleObject.new
      example_target = ::ExampleTarget.new
      example_target.id = 456
      emotion = Emotion.new(object: example_object, target: example_target, emotion: :example)
      assert_equal 'ExampleTarget:example:456:ExampleObject', emotion.target_key
    end

    def test_the_object_key_is_made_available_via_an_accessor
      example_object = ::ExampleObject.new
      example_object.id = 123
      example_target = ::ExampleTarget.new
      emotion = Emotion.new(object: example_object, target: example_target, emotion: :example)
      assert_equal 'ExampleObject:example:123:ExampleTarget', emotion.object_key
    end

  end

end
