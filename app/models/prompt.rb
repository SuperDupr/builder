# == Schema Information
#
# Table name: prompts
#
#  id          :bigint           not null, primary key
#  post_text   :string
#  pre_text    :string
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
  # Associations
  belongs_to :question
end