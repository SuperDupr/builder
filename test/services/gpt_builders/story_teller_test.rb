require "test_helper"

class StoryTellerTest < ActiveSupport::TestCase
  test "#finalized_data_feed" do
    story_teller = GptBuilders::StoryTeller.new(@options)
    story_teller.instance_variable_set(:@data, "User provided data!")

    assert_equal(
      story_teller.send(:finalized_data_feed),
      "Here is the conversational responses data received from user: #{story_teller.instance_variable_get(:@data)}" 
    )
  end

  test "#feed_data_to_ai" do
    stubbed_response = stubbed_ai_request("Here comes the response!")

    assert_equal(GptBuilders::StoryTeller.call(@options), stubbed_response)
  end

  test "#get_story_version" do
    stubbed_response = stubbed_ai_request("Here comes the response!")

    assert_equal(GptBuilders::StoryTeller.call(@options), stubbed_response)
  end

  test "data sorting functionality" do
    story_teller = GptBuilders::StoryTeller.new(@options)
    data = story_teller.instance_variable_get(:@data)
    
    assert_includes(data.keys, "key1")
    assert_includes(data.keys, "key2")
    
    key1_data = data["key1"]
    assert_equal 2, key1_data.length
  end
end
