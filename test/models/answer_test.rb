# == Schema Information
#
# Table name: answers
#
#  id          :bigint           not null, primary key
#  position    :integer
#  response    :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  prompt_id   :integer
#  question_id :bigint
#  story_id    :bigint
#
# Indexes
#
#  index_answers_on_question_id  (question_id)
#  index_answers_on_story_id     (story_id)
#
# Foreign Keys
#
#  fk_rails_...  (question_id => questions.id)
#  fk_rails_...  (story_id => stories.id)
#
require "test_helper"

class AnswerTest < ActiveSupport::TestCase
  def setup
    @answer = answers(:one)
  end

  test "belongs_to question association" do
    assert_respond_to @answer, :question
    assert_instance_of Question, @answer.question
  end

  test "belongs_to story association" do
    assert_respond_to @answer, :story
    assert_instance_of Story, @answer.build_story
  end
end
