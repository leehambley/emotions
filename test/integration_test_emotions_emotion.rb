require 'test_helper'

module Emotions
  
  class IntegrationTestEmotionsEmotion < Test::Integration::TestCase

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

      emotion = Emotion.new(object: example_object, target: example_target, emotion: :example)

      assert emotion.persist
      assert emotion.exists?

    end

  end

end
