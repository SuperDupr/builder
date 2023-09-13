# == Schema Information
#
# Table name: questionnaires
#
#  id               :bigint           not null, primary key
#  position         :integer
#  question_id      :bigint
#  story_builder_id :bigint
#
# Indexes
#
#  index_questionnaires_on_question_id       (question_id)
#  index_questionnaires_on_story_builder_id  (story_builder_id)
#
require "test_helper"

class QuestionnaireTest < ActiveSupport::TestCase
  def setup
    @questionnaire = questionnaires(:one)
  end

  test "acts_as_list inclusive modules" do
    assert_includes(Questionnaire.included_modules, ActiveRecord::Acts::List::NoUpdate)
    assert_includes(Questionnaire.included_modules, ActiveRecord::Acts::List::InstanceMethods)
  end

  test "belongs_to question association" do
    assert_respond_to(@questionnaire, :question)
    assert_instance_of(Question, @questionnaire.question)
  end

  test "belongs_to story_builder association" do
    assert_respond_to(@questionnaire, :story_builder)
    assert_instance_of(StoryBuilder, @questionnaire.story_builder)
  end
end
