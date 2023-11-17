# == Schema Information
#
# Table name: prompts
#
#  id          :bigint           not null, primary key
#  position    :integer
#  post_text   :string
#  pre_text    :string
#  selector    :string           is an Array
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
class Prompt < ApplicationRecord
  acts_as_list scope: :question

  # Associations
  belongs_to :question

  def full_sentence_form
    if pre_text && post_text
      "#{pre_text}_____#{post_text}"
    elsif pre_text
      "#{pre_text}_____"
    elsif post_text
      "_____#{post_text}"
    end
  end
end
