# ***Algorithm for parsing the AI prompt data***

# Q denotes Question
# P denotes Prompt
# A denotes Answer

# choice = "Q#1: P#1"

# A valid choice must have *Q* alphabet
# A valid choice can't have alphabets except *Q*, *P*
# A valid choice must contain alphabets in order of [Q, P] or simply [Q]
# A number must be preceeded by a hash (#)
# Each data aggregate is a combination of the sequence: [Q/P][#][(1..100)]
# A semi-colon must comes after the number except for the last number in the string

# Any other character presence except hash and space in the choice will make it invalid

# *Level #1: Validations*

# A valid choice must have *Q* alphabet
# A valid choice can't have alphabets except *Q*, *P*
# A valid choice must contain alphabets in order of [Q, P] or simply [Q]

# *Level #2: Validations*

# Each data aggregate is a combination of the sequence: [Q/P][#][(1..100)]
# A semi-colon must comes after the number except for the last number in the string
# (A semi-colon after the last number would be ignored)

# *Level #3: Breaking a valid choice*

# For example; choice = "Q#1: P#1"

# Extract counter parts:

# Q#1 -> Number after hash; Find question by position /1/
# P#1 -> Number after hash; Find question's prompt by position /1/

# Find the answer finally

class AiDataParser
  attr_accessor :data, :words

  def initialize(options = {})
    @story_id = options[:story_id]
    @data = options[:data]
    @words = []
  end

  def parse
    extract_words_and_add_answers
  end  

  private

  def extract_words_and_add_answers
    scanner = StringScanner.new(data)

    while scanner.scan_until(/\{\{([^{}]+)\}\}/)
      word = scanner[1]
      
      validator = WordValidator.new(word: word).call
      
      if validator[:success]
        # Find answer against the word
        answer = ExtractAnswer.new(word: validator[:word], story_id: @story_id).call || "answer_value"
        
        # Reform the string
        @words << word
        @data.sub!(word, answer)
      else
        @data.sub!(word, "______")
      end
    end
    # Finalize the original AI prompt associated with question
    @data.gsub(/{{\s*([^}]*)\s*}}/, '\1')
  end

  class WordValidator
    attr_accessor :word

    def initialize(word:)
      @word = word
      @success = false
    end

    def call
      eliminate_spaces_from_word
      sequence_and_format_validations
      { success: @success, word: word }
    end

    private

    def eliminate_spaces_from_word
      @word = @word.gsub(/\s+/, "")
    end

    def sequence_and_format_validations
      @success = /\AQ#(100|[1-9]\d?)(:P#(100|[1-9]\d?))?\z/.match?(word)
    end
  end

  class ExtractAnswer
    attr_reader :word

    def initialize(word:, story_id:)
      @word = word
      @story_id = story_id
    end

    def call
      extract_counter_parts
      # Find question
      # Find prompt if needed
      # Find answer
      # { answer: word }
    end

    private

    def extract_counter_parts
      target_objects = word.split(":")
      
      question_id = target_objects[0][-1]

      prompt_id = target_objects[1]&[-1]

      query_answer(question_id, prompt_id)
    end

    def query_answer(q_id, p_id)
      if q_id && p_id
        @story.answers.find_by(question_id: q_id)&.response
      else
        @story.answers.find_by(question_id: q_id, prompt_id: p_id)&.response
      end
    end
  end
end