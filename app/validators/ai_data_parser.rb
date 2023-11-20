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

  def initialize(story_id:, data:)
    @story = Story.find(story_id)
    @data = data
    @words = []
  end

  def parse
    scanner = StringScanner.new(data)

    while scanner.scan_until(/\{\{([^{}]+)\}\}/)
      word = eliminate_spaces_from_word(scanner[1])
      
      validator = WordValidator.new(word: word).call

      validator[:success] ? find_answer_and_substitute(word) : @data.sub!(word, "______")
    end

    unwrap_dynamic_content
  end  
  
  private
  
  # This method removes the curly braces and any surrounding 
  # spaces and leaves only the content inside.
  def unwrap_dynamic_content
    @data.gsub(/{{\s*([^}]*)\s*}}/, '\1')    
  end

  def eliminate_spaces_from_word(word)
    word.gsub(/\s+/, "")
  end

  def find_answer_and_substitute(word)
    answer = ExtractAnswer.new(word: word, story: @story).call || "______"

    @words << word
    @data.sub!(word, answer)
  end
  
  class WordValidator
    attr_accessor :word

    def initialize(word:)
      @word = word
      @success = false
    end

    def call
      sequence_and_format_validations
      { success: @success, word: word }
    end

    private

    def sequence_and_format_validations
      @success = /\AQ#(100|[1-9]\d?)(:P#(100|[1-9]\d?)(:A#(100|[1-9]\d?))?)?\z/.match?(word)
    end
  end

  class ExtractAnswer
    attr_reader :word

    def initialize(word:, story:)
      @word = word
      @story = story
    end

    def call
      extract_counter_parts
    end

    private

    def extract_counter_parts
      target_objects = word.split(":")
      question_position = target_objects[0][-1]

      if target_objects.size > 1
        prompt_position = target_objects[1][-1] || nil
        answer_position = target_objects.size == 3 ? target_objects[2][-1] : nil
      end
      
      query_answer(question_position, prompt_position, answer_position)
    end

    def query_answer(question_position, prompt_position, answer_position)
      if question_position && prompt_position && answer_position
        @story.answers.joins(question: :prompts).find_by(
          position: answer_position, 
          questions: { 
            position: question_position,
            prompts: { position: prompt_position }
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
        @story.answers.joins(:question).find_by(questions: { position: question_position })&.response
      end
    end
  end
end