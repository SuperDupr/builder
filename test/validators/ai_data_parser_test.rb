require "test_helper"

class AiDataParserTest < ActiveSupport::TestCase
  def setup
    @story = stories(:one)
    @ai_data_parser = AiDataParser.new(
      data: "data_to_be_parsed",
      story_id: @story.id
    )
  end

  test "#initialize" do
    assert_instance_of(AiDataParser, @ai_data_parser, "This is an instance of AI Data Parser")
    assert_equal(@ai_data_parser.data, "data_to_be_parsed")
  end

  test "#parse" do
    @ai_data_parser.data = "Pick up answer for question: {{Q#1}}"
    parsed_data = @ai_data_parser.parse

    assert_equal("Pick up answer for question: MyText", parsed_data)
  end

  test "#eliminate_spaces_from_wrapped_tags" do
    @ai_data_parser.data = "{{Q  A}}"

    assert_equal(@ai_data_parser.send(:eliminate_spaces_from_wrapped_tags), "{{QA}}")
  end

  test "#unwrap_dynamic_content" do
    @ai_data_parser.data = "{{Q#1}}"

    assert_equal(@ai_data_parser.send(:unwrap_dynamic_content), "Q#1")
  end

  test "#eliminate_spaces_from_word" do
    response = @ai_data_parser.send(:eliminate_spaces_from_word, "a b c")

    assert_equal(response, "abc")
  end

  test "#find_answer_and_substitute" do
    @ai_data_parser.data = "Here is my data: {{Q#1}}"
    @ai_data_parser.send(:find_answer_and_substitute, "Q#1")
    expected_response = answers(:one).response

    assert_equal(@ai_data_parser.data, "Here is my data: {{#{expected_response}}}")
  end

  test "AiDataParser::WordValidator" do
    @word_validator = AiDataParser::WordValidator.new(word: "Q#1")
    response = @word_validator.call

    assert_equal(response[:success], true)
  end

  test "AiDataParser::ExtractAnswer" do
    @extract_answer = AiDataParser::ExtractAnswer.new(word: "Q#1", story: @story)
    response = @extract_answer.call

    assert_equal(response, answers(:one).response)
  end
end
