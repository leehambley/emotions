require 'test_helper'

module Emotions

  class AcceptanceTestEmotionsEmotion < MiniTest::Acceptance::TestCase

    def test_checking_if_an_emotion_exists_checks_both_sides_of_the_relationship

      example_target = ::ExampleTarget.new
      example_object = ::ExampleObject.new

      example_object.id = 123
      example_target.id = 456

      emotion = Emotion.new({ target:  example_target,
                              object:  example_object,
                              emotion: :example })

      Emotions.backend = ::MiniTest::Mock.new

      Emotions.backend.expect(:read_sub_key, false, [emotion.target_key, example_object.id.to_s])
      Emotions.backend.expect(:read_sub_key, false, [emotion.object_key, example_target.id.to_s])

      refute emotion.exists?

      Emotions.backend.verify

    end

    def test_creating_an_emotion_creates_both_sides_of_the_relationship

      t = Time.now.utc

      example_target = ::ExampleTarget.new
      example_object = ::ExampleObject.new

      example_target.id = 123
      example_object.id = 456

      emotion = Emotion.new({ target:  example_target,
                              object:  example_object,
                              emotion: :example })

      Emotions.backend = ::MiniTest::Mock.new
      Emotions.backend.expect(:write_keys, true, [{ emotion.target_key => {example_object.id.to_s => t},
                                                    emotion.object_key => {example_target.id.to_s => t}}])

      emotion.persist(time: t)

      Emotions.backend.verify

    end

    def test_removing_an_emotion_removes_both_sides_of_the_relationship

      t = Time.now.utc

      example_target = ::ExampleTarget.new
      example_object = ::ExampleObject.new

      example_target.id = 123
      example_object.id = 456

      emotion = Emotion.new({ target:  example_target,
                              object:  example_object,
                              emotion: :example })

      Emotions.backend = ::MiniTest::Mock.new
      Emotions.backend.expect(:remove_sub_keys, true, [[ [emotion.target_key, example_object.id.to_s],
                                                         [emotion.object_key, example_target.id.to_s] ]])

      emotion.remove

      Emotions.backend.verify

    end

    def test_removing_one_emotion_without_removing_other_emotions

      t = Time.now.utc

      example_target     = ::ExampleTarget.new
      example_object_one = ::ExampleObject.new
      example_object_two = ::ExampleObject.new

      example_target.id     = 123
      example_object_one.id = 456
      example_object_two.id = 789

      emotion_one = Emotion.new({ target:  example_target,
                                  object:  example_object_one,
                                  emotion: :example })

      emotion_two = Emotion.new({ target:  example_target,
                                  object:  example_object_two,
                                  emotion: :example })

      Emotions.backend = ::MiniTest::Mock.new
      Emotions.backend.expect(:remove_sub_keys, true, [[ [emotion_one.target_key, example_object_one.id.to_s],
                                                         [emotion_one.object_key, example_target.id.to_s] ]])

      emotion_one.remove

      Emotions.backend.verify

    end

  end

end
