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
require "test_helper"

class StoryTest < ActiveSupport::TestCase
  def setup
    @story = stories(:one)
  end

  test "belongs_to story_builder association" do
    assert_respond_to @story, :story_builder
    assert_instance_of StoryBuilder, @story.story_builder
  end

  test "belongs_to creator association" do
    assert_respond_to @story, :creator
    assert_instance_of User, @story.creator
  end

  test "belongs_to account association" do
    assert_respond_to @story, :account
    assert_instance_of Account, @story.account
  end

  test "enum status values" do
    assert_equal({ "draft" => 0, "complete" => 1, "published" => 2 }, Story.statuses)
  end
end
