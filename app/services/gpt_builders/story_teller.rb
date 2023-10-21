module GptBuilders
  class StoryTeller < ApplicationService
    def initialize(options = {})
      @model = options[:model]
      @temperature = options[:temperature] || "some_default_temperature_value"
      @data = DataSorter.new(raw_data: options[:raw_data]).sort
    end

    def call
      feed_data_to_ai
    end

    def feed_data_to_ai
      @data
    end
  end

  class DataSorter
    def initialize(raw_data:)
      @raw_data = raw_data
      @sorted_data = {}
    end
    
    def sort
      drop_un_answered_questions!
      
      @raw_data.each do |entry|
        key = entry[1]

        answer_data = { "id" => entry[2], "response" => entry[3] }
              
        if entry[4].present? || entry[5].present?
          answer_data["prompt"] = { "pre_text" => entry[4], "post_text" => entry[5] }
        end

        @sorted_data[key] ||= []
        @sorted_data[key] << answer_data
      end

      @sorted_data
    end

    private

    def drop_un_answered_questions!
      @raw_data.select! { |entry| entry[2].present? }
    end
  end
end
