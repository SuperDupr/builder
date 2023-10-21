# Take the builder's ai_prompt text and send it to OpenAI service class
# Meanwhile we have to establish the connection to F.E. (StoryCreationChannel <-> StimulusController)
# Once this job get's completed we have to emit a completion event to F.E.
# Send the story content to StimulusController

class StoryCreatorJob < ApplicationJob
  queue_as :default

  def perform(options = {})
    GptBuilders::StoryTeller.call({
      raw_data: options[:raw_data],
      model: "gpt-3.5-turbo",
      system_ai_prompt: options[:system_ai_prompt],
      admin_ai_prompt: options[:admin_ai_prompt]
    })
  end

  after_perform do |job|
    ActionCable.server.broadcast("story_generation", { body: "It's time to hide spinner!" })
  end
end
