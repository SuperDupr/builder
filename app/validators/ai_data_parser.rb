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

# Each data aggregate is a combination of the sequence: [Q/P/A][#][(1..100)]
# A semi-colon must comes after the number except for the last number in the string
# (A semi-colon after the last number would be ignored)

# *Level #3: Breaking a valid choice*

# For example; choice = "Q#1: P#1: A#1"

# Extract counter parts:

# Q#1 -> Number after hash; Find question by position /1/
# P#1 -> Number after hash; Find question's prompt by position /1/

# Find the answer finally


class AiDataParser
  attr_accessor :data
  
  def initialize(options={})
    @data = options[:data]
  end
end
