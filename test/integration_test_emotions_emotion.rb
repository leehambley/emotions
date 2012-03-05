require 'test_helper'

module Emotions
  
  class IntegrationTestEmotionsEmotion < MiniTest::Integration::TestCase

    def test_emotions_do_not_exist_until_persisted

      example_object = ExampleObject.new
      example_object.class.send(:define_method, :id, lambda { 123 })

      example_target = ExampleTarget.new
      example_target.class.send(:define_method, :id, lambda { 456 })

      emotion = Emotion.new(object: example_object, target: example_target, emotion: :example)

      refute emotion.exists?

    end

    def test_emotions_exist_once_persisted

      example_object = ExampleObject.new
      example_object.class.send(:define_method, :id, lambda { 123 })

      example_target = ExampleTarget.new
      example_target.class.send(:define_method, :id, lambda { 456 })

      emotion_one = Emotion.new(object: example_object, target: example_target, emotion: :example)

      refute emotion_one.exists?
      assert emotion_one.persist
      assert emotion_one.exists?

    end

    def test_emotions_that_are_the_same_can_be_treated_as_equal

      example_object = ExampleObject.new
      example_object.class.send(:define_method, :id, lambda { 123 })

      example_target = ExampleTarget.new
      example_target.class.send(:define_method, :id, lambda { 456 })

      emotion_one = Emotion.new(object: example_object, target: example_target, emotion: :example)
      emotion_two = Emotion.new(object: example_object, target: example_target, emotion: :example)

      refute emotion_one.exists?
      refute emotion_two.exists?

      [emotion_one, emotion_two].sample.persist

      assert emotion_one.exists?
      assert emotion_two.exists?

    end

  end

end
