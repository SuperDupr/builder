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
  has_one :answer, dependent: :destroy

  has_and_belongs_to_many :story_builders

  accepts_nested_attributes_for :prompts, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :parent_nodes, reject_if: :all_blank, allow_destroy: true
end