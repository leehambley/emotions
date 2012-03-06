require 'test_helper'

module Emotions

  class AcceptanceTestEmotionsKeyLoader < MiniTest::Acceptance::TestCase

    def test_it_should_call_find_for_both_keys

      t = Time.now.utc

      example_object = ExampleObject.new(123)
      example_target = ExampleTarget.new(456)

      kl = KeyLoader.new("ExampleTarget:emotion:123:ExampleObject", 123)

      assert_equal example_object, kl.object
      assert_equal example_target, kl.target
      assert_equal :emotion, kl.emotion
      assert_equal t, kl.time

    end

  end

end
