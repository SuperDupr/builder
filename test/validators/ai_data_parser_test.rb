require "test_helper"

class AiDataParserTest < ActiveSupport::TestCase
  test "#initialize" do
    ai_data_parser = AiDataParser.new({ data: "some_random_data" })

    assert_instance_of(AiDataParser, ai_data_parser, "This is an instance of AI Data Parser")
    assert_equal(ai_data_parser.data, "some_random_data")
  end
end
