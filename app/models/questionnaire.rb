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
class Questionnaire < ApplicationRecord
  acts_as_list

  belongs_to :question
  belongs_to :story_builder
end
