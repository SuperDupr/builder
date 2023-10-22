module GptBuilders
  class StoryTeller < ApplicationService
    def initialize(options = {})
      @openai_client = OpenAI::Client.new
      @model = options[:model]
      @temperature = options[:temperature] || 0.2
      @system_ai_prompt = options[:system_ai_prompt]
      @admin_ai_prompt = options[:admin_ai_prompt]
      @data = DataSorter.new(raw_data: options[:raw_data]).sort
    end

    def call
      feed_data_to_ai
      get_story_version
    end

    private
    
    def finalized_system_ai_prompt
      return @system_ai_prompt if @admin_ai_prompt.nil?
      "#{@system_ai_prompt}. User specific instructions to supersede: #{@admin_ai_prompt}"
    end

    def finalized_data_feed
      "Here is the conversational responses data received from user: #{@data}"
    end
    
    def feed_data_to_ai
      @response = @openai_client.chat(
        parameters: {
          model: @model,
          messages: [
            { role: "system", content: finalized_system_ai_prompt },
            { role: "user", content: finalized_data_feed }
          ],
          temperature: @temperature
        }
      )
    end

    def get_story_version
      puts; puts; puts @response; puts; puts
      @response.dig("choices", 0, "message", "content")
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
