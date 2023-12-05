# == Schema Information
#
# Table name: prompts
#
#  id          :bigint           not null, primary key
#  position    :integer
#  post_text   :string
#  pre_text    :string
#  selector    :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  question_id :bigint
#
# Indexes
#
#  index_prompts_on_question_id  (question_id)
#
# Foreign Keys
#
#  fk_rails_...  (question_id => questions.id)
#
require "test_helper"

class PromptTest < ActiveSupport::TestCase
  def setup
    @prompt = prompts(:one)
  end

  test "belongs_to question association" do
    assert_respond_to @prompt, :question
    assert_instance_of Question, @prompt.question
  end

  test "full_sentence_form method" do
    assert_respond_to @prompt, :full_sentence_form

    @prompt.pre_text = "Before"
    @prompt.post_text = "After"
    assert_equal "Before_____After", @prompt.full_sentence_form

    @prompt.pre_text = "Before"
    @prompt.post_text = nil
    assert_equal "Before_____", @prompt.full_sentence_form

    @prompt.pre_text = nil
    @prompt.post_text = "After"
    assert_equal "_____After", @prompt.full_sentence_form

    @prompt.pre_text = nil
    @prompt.post_text = nil
    assert_nil @prompt.full_sentence_form
  end
end
