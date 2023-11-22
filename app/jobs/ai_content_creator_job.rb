class AiContentCreatorJob < ApplicationJob
  queue_as :default

  def perform(options = {})
    @current_user = options[:current_user]
    @dynamic_content = options[:content]

    sleep(2)

    @response = GptBuilders::StoryTeller.call({
      model: "gpt-3.5-turbo",
      admin_ai_prompt: @dynamic_content
    })
  end

  after_perform do |job|
    AiContentGenerationChannel.broadcast_to(@current_user, body: @response)
  end
end
