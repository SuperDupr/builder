# == Schema Information
#
# Table name: story_builders
#
#  id         :bigint           not null, primary key
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class StoryBuilder < ApplicationRecord
  # Associations
  has_and_belongs_to_many :questions
  has_many :stories, dependent: :destroy
end
