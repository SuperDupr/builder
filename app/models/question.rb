# == Schema Information
#
# Table name: questions
#
#  id         :bigint           not null, primary key
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Question < ApplicationRecord
  # Associations
  has_many :prompts, dependent: :destroy
  has_many :parent_nodes, dependent: :destroy
  has_many :answers, dependent: :destroy

  has_many :questionnaires
  has_many :story_builders, through: :questionnaires

  accepts_nested_attributes_for :prompts, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :parent_nodes, reject_if: :all_blank, allow_destroy: true

  # Class methods
  def self.questionnaires_conversational_data(story_id:)
    joins("LEFT JOIN answers ON questions.id = answers.question_id AND answers.story_id = #{story_id}
      LEFT JOIN prompts ON questions.id = prompts.question_id")
      .pluck(
        "questions.title",
        "answers.id",
        "answers.response",
        Arel.sql("COALESCE(prompts.pre_text, '') as pre_text"),
        Arel.sql("COALESCE(prompts.post_text, '') as post_text")
      )
  end
end
