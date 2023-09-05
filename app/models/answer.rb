# == Schema Information
#
# Table name: answers
#
#  id          :bigint           not null, primary key
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
class Answer < ApplicationRecord
  # Associations
  belongs_to :question
  belongs_to :story
end
