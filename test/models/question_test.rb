# == Schema Information
#
# Table name: questions
#
#  id                      :bigint           not null, primary key
#  active                  :boolean          default(TRUE)
#  ai_prompt               :text
#  ai_prompt_attached      :boolean          default(FALSE)
#  multiple_node_selection :boolean          default(FALSE)
#  position                :integer
#  title                   :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  story_builder_id        :integer
#
require "test_helper"

class QuestionTest < ActiveSupport::TestCase
  def setup
    @question = questions(:one)
  end

  test "has_many prompts association" do
    assert_respond_to @question, :prompts
    assert_instance_of Prompt, @question.prompts.build
  end

  test "has_many parent_nodes association" do
    assert_respond_to @question, :parent_nodes
    assert_instance_of ParentNode, @question.parent_nodes.build
  end

  test "has_many answers association" do
    assert_respond_to @question, :answers
    assert_instance_of Answer, @question.answers.build
  end

  test "has_many questionnaires association" do
    assert_respond_to @question, :questionnaires
    assert_instance_of Questionnaire, @question.questionnaires.build
  end

  test "has_many story_builders through questionnaires association" do
    assert_respond_to @question, :story_builders
    assert_instance_of StoryBuilder, @question.story_builders.build
  end

  test "accepts_nested_attributes_for prompts" do
    assert_respond_to @question, :prompts_attributes=
  end

  test "accepts_nested_attributes_for parent_nodes" do
    assert_respond_to @question, :parent_nodes_attributes=
  end

  # Class methods
  test "#self.questionnaires_conversational_data(story_id:)" do
    raw_data = Question.questionnaires_conversational_data(story_id: stories(:one).id)

    assert_includes(Question.methods, :questionnaires_conversational_data)
    assert_includes(raw_data[0], @question.id)
    assert_includes(raw_data[1], questions(:two).id)
  end
end
