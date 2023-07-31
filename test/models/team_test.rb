# == Schema Information
#
# Table name: teams
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  account_id :bigint           not null
#
# Indexes
#
#  index_teams_on_account_id  (account_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#
require "test_helper"

class TeamTest < ActiveSupport::TestCase
  def setup
    @associations_reflector = Team.reflect_on_all_associations
  end

  test "Associations" do
    assoc_classes = @associations_reflector.map { |assoc_ref| assoc_ref.class }
    assoc_names = @associations_reflector.map { |assoc_ref| assoc_ref.name }
    
    assert_includes(assoc_classes, ActiveRecord::Reflection::BelongsToReflection)
    assert_includes(assoc_names, :account)

    assert_includes(assoc_classes, ActiveRecord::Reflection::HasManyReflection)
    assert_includes(assoc_names, :users)
  end

  test "Validations" do
    team = Team.new(name: "")

    assert(team.invalid?, true)
  end
end
