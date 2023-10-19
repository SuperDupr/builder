module GptBuilders
  class StoryTeller < ApplicationService
    def initialize(options = {})
      @model = options[:model]
      @temperature = options[:temperature] || "some_default_temperature_value"
      @raw_data = options[:raw_data]
    end

    def call
      sort_data_for_ai
      feed_data_to_ai
    end

    private

    def sort_data_for_ai
      raise NotImplementedError
    end

    def feed_data_to_ai
      raise NotImplementedError
    end
  end
end
