# AiDataParser is responsible for parsing AI-generated data with placeholders
# and substituting them with corresponding answers from the database.

# Valid Combinations:

# Q#1
# Q#100
# Q#1:P#2
# Q#100:P#99:A#3
# Invalid Combinations:

# Q#0 (Invalid position; should start from 1)
# Q#01 (Invalid leading zero in the position)
# Q#101 (Position cannot be greater than 100)
# Q#1:P#0 (Invalid position for Prompt; should start from 1)
# Q#1:A#01 (Invalid leading zero in the position for Answer)
# Q#1:A#1 (Invalid as Answer position relies on Prompts)
class AiDataParser
  attr_accessor :data, :words

  # Initializes an AiDataParser instance with the given story_id and data.
  # The story_id is used to retrieve answers from the database.
  #
  # @param story_id [Integer] ID of the story.
  # @param data [String] AI-enabled data with placeholders.
  def initialize(story_id:, data:)
    @story = Story.find(story_id)
    @data = data
    @words = []
  end

  # Parses the AI-generated data and substitutes placeholders with answers.
  # The parsed data is returned.
  #
  # @return [String] Parsed data with substituted answers.
  def parse
    return "" if @data.nil?

    scanner = StringScanner.new(data)

    eliminate_spaces_from_wrapped_tags

    while scanner.scan_until(/\{\{([^{}]+)\}\}/)
      word = eliminate_spaces_from_word(scanner[1])

      validator = WordValidator.new(word: word).call

      validator[:success] ? find_answer_and_substitute(word) : @data.sub!(word, "______")
    end

    unwrap_dynamic_content
  end

  private

  # Eliminates spaces from wrapped tags in the data.
  def eliminate_spaces_from_wrapped_tags
    @data = @data.gsub(/\{\{([^{}]+)\}\}/) { |match| match.gsub(/\s+/, "") }
  end

  # This method removes the curly braces and any surrounding
  # spaces and leaves only the content inside.
  def unwrap_dynamic_content
    @data.gsub(/{{\s*([^}]*)\s*}}/, '\1')
  end

  # Eliminates spaces from a word.
  #
  # @param word [String] The word to process.
  # @return [String] The word with spaces eliminated.
  def eliminate_spaces_from_word(word)
    word.gsub(/\s+/, "")
  end

  # Finds the answer corresponding to the given word and substitutes it in the data.
  #
  # @param word [String] The placeholder word.
  def find_answer_and_substitute(word)
    answer = ExtractAnswer.new(word: word, story: @story).call || "______"

    @words << word
    @data.sub!(word, answer)
  end

  # WordValidator class validates the format of a word.
  class WordValidator
    attr_accessor :word

    # Initializes a WordValidator instance with the given word.
    #
    # @param word [String] The word to validate.
    def initialize(word:)
      @word = word
      @success = false
    end

    # Validates the format of the word and returns a hash indicating success.
    #
    # @return [Hash] Validation result with success status and word.
    def call
      sequence_and_format_validations
      {success: @success, word: word}
    end

    private

    # Performs sequence and format validations on the word.
    def sequence_and_format_validations
      @success = /\AQ#(100|[1-9]\d?)(:P#(100|[1-9]\d?)(:A#(100|[1-9]\d?))?)?\z/.match?(word)
    end
  end

  class ExtractAnswer
    attr_reader :word

    # Initializes an ExtractAnswer instance with the given word and story.
    #
    # @param word [String] The placeholder word.
    # @param story [Story] The story from which to retrieve answers.
    def initialize(word:, story:)
      @word = word
      @story = story
    end

    # Extracts and returns the answer corresponding to the word.
    #
    # @return [String, nil] The extracted answer or nil if not found.
    def call
      extract_counter_parts
    end

    private

    # Extracts counter parts from the word and queries the database for the answer.
    def extract_counter_parts
      target_objects = word.split(":")
      question_position = target_objects[0][-1]

      if target_objects.size > 1
        prompt_position = target_objects[1][-1] || nil
        answer_position = (target_objects.size == 3) ? target_objects[2][-1] : nil
      end

      query_answer(question_position, prompt_position, answer_position)
    end

    # Queries the database for the answer based on counter parts.
    def query_answer(question_position, prompt_position, answer_position)
      if question_position && prompt_position && answer_position
        @story.answers.joins(question: :prompts).find_by(
          position: answer_position,
          questions: {
            position: question_position,
            prompts: {position: prompt_position}
          }
        )&.response
      elsif question_position && prompt_position
        @story.answers.joins(question: :prompts).find_by(
          questions: {
            position: question_position,
            prompts: {
              position: prompt_position
            }
          }
        )&.response
      else
        @story.answers.joins(:question).find_by(questions: {position: question_position})&.response
      end
    end
  end
end
