require "test_helper"

class StoryTellerTest < ActiveSupport::TestCase
  # def setup
  #   @options = {
  #     model: "gpt-3.5-turbo",
  #     raw_data: [
  #       [1, "key1", 1, "response1", "pre1", "post1"],
  #       [2, "key1", 2, "response2", nil, nil],
  #       [3, "key2", 3, "response3", "pre3", "post3"]
  #     ]
  #   }
  # end

  # def test_feed_data_to_ai
  #   # Create a mock OpenAI client
  #   openai_client = Minitest::Mock.new

  #   # Define the expected parameters for the chat method
  #   expected_parameters = {
  #     model: @options[:model],
  #     messages: [
  #       {role: "system", content: "Expected System AI Prompt"},
  #       {role: "user", content: "Expected Data Feed"}
  #     ],
  #     temperature: 0.2
  #   }

  #   # Expect the chat method to be called with the expected parameters
  #   openai_client.expect :chat, "Response from OpenAI", [expected_parameters]

  #   # Instantiate StoryTeller with the mock OpenAI client
  #   storyteller = GptBuilders::StoryTeller.new(@options)
  #   storyteller.instance_variable_set(:@openai_client, openai_client)

  #   storyteller.call

  #   openai_client.verify
  # end

  # def test_get_story_version
  #   # Prepare a response hash
  #   response = { "choices" => [{ "message" => { "content" => "Generated Story" } }] }

  #   # Create a mock OpenAI client
  #   openai_client = Minitest::Mock.new
  #   openai_client.expect :chat, response, [Hash]

  #   # Instantiate StoryTeller with the mock OpenAI client
  #   storyteller = GptBuilders::StoryTeller.new(@options)
  #   storyteller.instance_variable_set(:@openai_client, openai_client)

  #   assert_equal "Generated Story", storyteller.call
  #   openai_client.verify
  # end

  # def test_data_sorter
  #   storyteller = GptBuilders::StoryTeller.new(@options)
  #   sorted_data = storyteller.call

  #   # Assert that sorted_data contains the expected keys
  #   assert_includes sorted_data.keys, "key1"
  #   assert_includes sorted_data.keys, "key2"

  #   # Assert that sorted_data["key1"] contains the expected data
  #   key1_data = sorted_data["key1"]
  #   assert_equal 2, key1_data.length

  #   # Assert that sorted_data["key2"] contains the expected data
  #   key2_data = sorted_data["key2"]
  #   assert_equal 1, key2_data.length
  # end
end
