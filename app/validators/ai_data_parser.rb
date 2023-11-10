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
    @data = options[:data]
    @words = []
  end

  def parse
    extract_words_and_add_answers
    # level_one_validations
  end  

  private

  def extract_words_and_add_answers
    scanner = StringScanner.new(data)

    while scanner.scan_until(/\{\{([^{}]+)\}\}/)
      word = scanner[1]

      # Run validations on word
      validator = WordValidator.new(word: word).call

      if validator[:success]
        # Extract counter parts
        counter_parts = ExtractAnswer.new(word: word).call if validator[:success]
        # Find answer against the word
        
        # Reform the string
        @data[scanner[1]] = answer
      else
        "Please answer according to your own mindset and information!"
      end
      # To be decided
      # @words << word
    end
    # Finalize the original AI prompt associated with question
    @data
  end

  # *Level #1: Validations*

  # A valid choice must have *Q* alphabet
  # A valid choice can't have alphabets except *Q*, *P*
  # A valid choice must contain alphabets in order of [Q, P] or simply [Q]

  # Q or P
  class WordValidator
    def initialize(word:)
      @word = word
    end

    def call
      # level_one_validations
      # level_two_validations
      { success: true, word: @word }
    end

    def level_one_validations
    end
    
    def level_two_validations
    end
  end

  class ExtractAnswer
    def initialize(word:)
      @word = word
    end

    def call
      # Find question
      # Find prompt if needed
      # Find answer
      { answer: @answer }
    end
  end
end