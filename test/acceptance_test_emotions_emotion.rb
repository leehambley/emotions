require 'test_helper'

module Emotions

  class AcceptanceTestEmotionsEmotion < MiniTest::Acceptance::TestCase

    def test_checking_if_an_emotion_exists
      
      example_target = ::ExampleTarget.new
      example_object = ::ExampleObject.new

      example_target.class.send(:define_method, :id, lambda { 123 })
      example_object.class.send(:define_method, :id, lambda { 456 })

      emotion = Emotion.new({ target:  example_target,
                              object:  example_object,
                              emotion: :example })

      Emotions.backend = ::MiniTest::Mock.new
      Emotions.backend.expect(:read_sub_key, false, [emotion.target_key, example_target.id.to_s])
      
      emotion.exists?
      
      Emotions.backend.verify

    end

    def test_creating_an_emotion
     
      t = Time.now

      example_target = ::ExampleTarget.new
      example_object = ::ExampleObject.new

      example_target.class.send(:define_method, :id, lambda { 123 })
      example_object.class.send(:define_method, :id, lambda { 456 })

      emotion = Emotion.new({ target:  example_target,
                              object:  example_object,
                              emotion: :example })

      Emotions.backend = ::MiniTest::Mock.new
      Emotions.backend.expect(:write_keys, true, [{ emotion.target_key => {example_object.id => t}, 
                                                    emotion.object_key => {example_target.id => t}}])

      emotion.persist(time: t)

      Emotions.backend.verify

    end

    def test_removing_an_emotion
     
      t = Time.now

      example_target = ::ExampleTarget.new
      example_object = ::ExampleObject.new

      example_target.class.send(:define_method, :id, lambda { 123 })
      example_object.class.send(:define_method, :id, lambda { 456 })

      emotion = Emotion.new({ target:  example_target,
                              object:  example_object,
                              emotion: :example })

      Emotions.backend = ::MiniTest::Mock.new
      Emotions.backend.expect(:remove_sub_keys, true, [[ [emotion.target_key, example_object.id.to_s], [emotion.object_key, example_target.id.to_s] ]])

      emotion.remove

      Emotions.backend.verify

    end

    def test_removing_one_emotion_without_removing_other_emotions

      t = Time.now

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
      Emotions.backend.expect(:remove_sub_keys, true, [[ [emotion_one.target_key, example_object_one.id.to_s], [emotion_one.object_key, example_target.id.to_s] ]])

      emotion_one.remove

      Emotions.backend.verify

    end

  end

end
