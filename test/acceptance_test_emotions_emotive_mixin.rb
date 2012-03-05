require 'test_helper'

module Emotions

  class AcceptanceTestEmptionsEmotive < MiniTest::Acceptance::TestCase

    def test_mixing_in_emotive_makes_the_emotions_method_available

      refute ExampleTarget.respond_to?(:emotions)
      ExampleTarget.send(:include, Emotive)
      assert ExampleTarget.respond_to?(:emotions)

    end

    def test_using_the_emotive_emotions_method_registers_them_as_supported_emotions
      
      ExampleTarget.send(:include, Emotive)
      ExampleTarget.send(:emotions, :example_one, :example_two, :example_three)

      assert_equal [:example_one, :example_two, :example_three], ExampleTarget.registered_emotions
      
    end

    def test_the_registered_emotions_have_their_instance_methods_created
    
      ExampleTarget.send(:include, Emotive)
      ExampleTarget.send(:emotions, :example_emotion)

      assert ExampleTarget.new.respond_to?(:example_emotion_by)
      assert ExampleTarget.new.respond_to?(:cancel_example_emotion_by)
      # assert ExampleTarget.new.respond_to?(:example_emotion_emotes)

    end

  end

end
