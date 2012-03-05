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

    def test_creating_an_emotion_persits_it_to_the_backend

      t = Time.now

      ExampleTarget.send(:include, Emotive)
      ExampleTarget.send(:emotions, :example_emotion)

      example_object = ExampleObject.new
      example_object.id = 123

      example_target = ExampleTarget.new
      example_target.id = 456

      Emotions.backend = ::MiniTest::Mock.new
      Emotions.backend.expect(:write_keys, true, [{ 'example_object:example_emotion:123:example_target' => {'456' => t},
                                                    'example_target:example_emotion:456:example_object' => {'123' => t} }])

      assert_equal true, example_target.example_emotion_by(example_object, t)

      Emotions.backend.verify

    end

    def test_calcelling_an_emotion_removes_both_sides_of_the_relationship_from_the_backend

      t = Time.now

      ExampleTarget.send(:include, Emotive)
      ExampleTarget.send(:emotions, :example_emotion)

      example_object = ExampleObject.new
      example_object.id = 123

      example_target = ExampleTarget.new
      example_target.id = 456

      Emotions.backend = ::MiniTest::Mock.new
      Emotions.backend.expect(:remove_sub_keys, true, [[["example_target:example_emotion:456:example_object", "123"], ["example_object:example_emotion:123:example_target", "456"]]])

      assert_equal true, example_target.cancel_example_emotion_by(example_object)

      Emotions.backend.verify

    end

    def test_something_about_retreiving_emotions
      skip
    end

  end

end
