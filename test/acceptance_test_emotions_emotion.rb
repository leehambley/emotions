require 'test_helper'

module Emotions

  class AcceptanceTestEmotionsEmotion < Test::Acceptance::TestCase

    def test_checking_if_an_emotion_exists
      
      example_target = ::ExampleTarget.new
      example_object = ::ExampleObject.new

      example_target.class.send(:define_method, :id, lambda { 123 })
      example_object.class.send(:define_method, :id, lambda { 456 })

      emotion = Emotion.new({ target:  example_target,
                              object:  example_object,
                              emotion: :example })

      Emotions.backend = MiniTest::Mock.new
      Emotions.backend.expect(:key_exists?, false, [emotion.target_key])
      
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

      Emotions.backend = MiniTest::Mock.new
      Emotions.backend.expect(:write_keys, true, [{ emotion.target_key => {created_at: t}, 
                                                    emotion.object_key => {created_at: t}}])

      emotion.persist(time: t)

      Emotions.backend.verify

    end

  end

end
