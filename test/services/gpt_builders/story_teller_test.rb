require "test_helper"

class StoryTellerTest < ActiveSupport::TestCase
  def setup
    @options = {
      raw_data: [
        [1, "key1", 1, "response1", "pre1", "post1"],
        [2, "key1", 2, "response2", nil, nil],
        [3, "key2", 3, "response3", "pre3", "post3"]
      ],
      model: "gpt-3.5-turbo",
      admin_ai_prompt: "Nothing specific"
    }
  end

  def stubbed_ai_request(stubbed_response)
    stub_request(:post, "https://api.openai.com/v1/chat/completions")
      .with(
        body: "{\"model\":\"gpt-3.5-turbo\",\"messages\":[{\"role\":\"system\",\"content\":\"Nothing specific\"}],\"temperature\":0.2}",
        headers: {
          "Accept" => "*/*",
          "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          "Content-Type" => "application/json",
          "User-Agent" => "Ruby"
        }
      )
      .to_return(status: 200, body: {
        choices: [
          {message: {content: stubbed_response}}
        ]
      }.to_json, headers: {})

    stubbed_response
  end

  test "#call" do
    story_teller = GptBuilders::StoryTeller.new(@options)

    story_teller.stub(:feed_data_to_ai, "Result from data fed") do
      story_teller.stub(:get_story_version, "Result from story version") do
        story_teller.call
      end
    end
  end

  test "#feed_data_to_ai" do
    stubbed_response = stubbed_ai_request("Here comes the response!")

    assert_equal(GptBuilders::StoryTeller.call(@options), stubbed_response)
  end

  test "#get_story_version" do
    stubbed_response = stubbed_ai_request("Here comes the response!")

    assert_equal(GptBuilders::StoryTeller.call(@options), stubbed_response)
  end

  # test "data sorting functionality" do
  #   story_teller = GptBuilders::StoryTeller.new(@options)
  #   data = story_teller.instance_variable_get(:@data)

  #   assert_includes(data.keys, "key1")
  #   assert_includes(data.keys, "key2")

  #   key1_data = data["key1"]
  #   assert_equal 2, key1_data.length
  # end
end
