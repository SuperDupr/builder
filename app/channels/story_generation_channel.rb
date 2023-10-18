class StoryGenerationChannel < ApplicationCable::Channel
  def subscribed
    stream_from("story_generation")
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
