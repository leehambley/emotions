require 'test_helper'

module Emotions

  class IntegrationTestEmptionsEmotive < MiniTest::Integration::TestCase

    def test_being_emoted_by_any_conforming_object

      example_object = ExampleObject.new
      example_object.id = 123

      ExampleTarget.send(:include, Emotive)
      ExampleTarget.send(:emotions, :example)

      example_target = ExampleTarget.new
      example_target.id = 456

      example_target.example_by(example_object)

      assert Emotion.new(target: example_target, object: example_object, emotion: :example).exists?

    end

    def test_cancelling_an_emote_by_any_conforming_object

      example_object = ExampleObject.new
      example_object.id = 123

      ExampleTarget.send(:include, Emotive)
      ExampleTarget.send(:emotions, :example)

      example_target = ExampleTarget.new
      example_target.id = 456

      expected_emotion = Emotion.new(target: example_target, object: example_object, emotion: :example)
      expected_emotion.persist

      example_target.cancel_example_by(example_object)

      refute Emotion.new(target: example_target, object: example_object, emotion: :example).exists?

    end

    def test_counting_the_number_of_emotes

      skip

      example_object_one = ExampleObject.new
      example_object_one.id = 123

      example_object_two = ExampleObject.new
      example_object_two.id = 456

      ExampleTarget.send(:include, Emotive)
      ExampleTarget.send(:emotions, :example)

      example_target = ExampleTarget.new
      example_target.id = 456

      expected_emotion_one = Emotion.new(target: example_target, object: example_object_one, emotion: :example)
      expected_emotion_one.persist

      expected_emotion_two = Emotion.new(target: example_target, object: example_object_two, emotion: :example)
      expected_emotion_two.persist

      assert_equal 2, example_target.example_emotes.count

    end


  end

end
