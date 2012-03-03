require 'test_helper'

module Emotions

  class UnitTestEmotion < Test::Unit::TestCase

    def test_an_argument_error_is_raised_when_instantiated_without_a_target
      assert_raises KeyError do
        Emotion.new({object: true, emotion: true})
      end
    end

    def test_an_argument_error_is_raised_when_instantiated_without_an_object
      assert_raises KeyError do
        Emotion.new({emotion: true, target: true})
      end
    end

    def test_an_argument_error_is_raised_when_instantiated_without_an_emotion
      assert_raises KeyError do
        Emotion.new({object: true, target: true})
      end
    end

    def test_the_target_is_readable_via_an_accessor
      assert_equal :example, Emotion.new({object: true, target: :example, emotion: true}).target
    end

    def test_the_object_is_readable_via_an_accessor
      assert_equal :example, Emotion.new({object: :example, target: true, emotion: true}).object
    end

    def test_the_emotion_is_readable_via_an_accessor
      assert_equal :example, Emotion.new({object: true, target: true, emotion: :example}).emotion
    end

    def test_the_target_key_is_made_available_via_an_accessor
      example_object = ::ExampleObject.new
      example_object.class.send(:define_method, :id, lambda { 123 })
      example_target = ::ExampleTarget.new
      example_target.class.send(:define_method, :id, lambda { 456 })
      emotion = Emotion.new({object: example_object, target: example_target, emotion: :example})
      assert_equal 'example_target:456:example:example_object:123', emotion.target_key
    end

    def test_the_object_key_is_made_available_via_an_accessor
      example_object = ::ExampleObject.new
      example_object.class.send(:define_method, :id, lambda { 123 })
      example_target = ::ExampleTarget.new
      example_target.class.send(:define_method, :id, lambda { 456 })
      emotion = Emotion.new({object: example_object, target: example_target, emotion: :example})
      assert_equal 'example_object:123:example:example_target:456', emotion.object_key
    end

  end

end
