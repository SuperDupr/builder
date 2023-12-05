require "test_helper"

class StoryCreatorJobTest < ActiveJob::TestCase
  include ActionCable::TestHelper

  def setup
    @user = users(:one)

    sign_in(@user)
  end

  def stubbed_ai_request(stubbed_response)
    stub_request(:post, "https://api.openai.com/v1/chat/completions")
      .with(
        body: "{\"model\":\"gpt-3.5-turbo\",\"messages\":[{\"role\":\"system\",\"content\":\"Nothing special!\"}],\"temperature\":0.2}",
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

  test "#perform" do
    story = stories(:one)
    stubbed_response = "This is some stubbed response!"
    stubbed_ai_request(stubbed_response)

    response = StoryCreatorJob.perform_now({
      current_user: @user,
      story: story,
      raw_data: Question.questionnaires_conversational_data(story_id: story.id),
      admin_ai_prompt: "Nothing special!"
    })

    assert_equal(response, stubbed_response)
    assert_equal(story.ai_generated_content, stubbed_response)
  end
end
