# == Schema Information
#
# Table name: story_builders
#
#  id               :bigint           not null, primary key
#  admin_ai_prompt  :text
#  system_ai_prompt :text
#  title            :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
require "test_helper"

class StoryBuilderTest < ActiveSupport::TestCase
  def setup
    @story_builder = story_builders(:one)
  end

  test "has_many questionnaires association" do
    assert_respond_to @story_builder, :questionnaires
    assert_instance_of Questionnaire, @story_builder.questionnaires.build
  end

  test "has_many questions through questionnaires association" do
    assert_respond_to @story_builder, :questions
    assert_instance_of Question, @story_builder.questions.build
  end

  test "has_many stories association" do
    assert_respond_to @story_builder, :stories
    assert_instance_of Story, @story_builder.stories.build
  end
end
