# == Schema Information
#
# Table name: stories
#
#  id               :bigint           not null, primary key
#  private          :boolean          default(TRUE)
#  status           :integer          default("draft")
#  title            :string
#  viewable         :boolean          default(FALSE)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  account_id       :bigint
#  creator_id       :bigint
#  story_builder_id :bigint
#
# Indexes
#
#  index_stories_on_account_id        (account_id)
#  index_stories_on_creator_id        (creator_id)
#  index_stories_on_story_builder_id  (story_builder_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (creator_id => users.id)
#  fk_rails_...  (story_builder_id => story_builders.id)
#
class Story < ApplicationRecord
  enum status: [:draft, :complete, :published]

  # Associations
  belongs_to :story_builder
  belongs_to :creator, class_name: "User"
  belongs_to :account
end
