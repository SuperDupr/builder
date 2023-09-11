# == Schema Information
#
# Table name: industries
#
#  id         :bigint           not null, primary key
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  account_id :bigint
#
# Indexes
#
#  index_industries_on_account_id  (account_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#
require "test_helper"

class IndustryTest < ActiveSupport::TestCase
  def setup
    @industry = industries(:one)
  end

  test "belongs_to account association" do
    assert_respond_to(@industry, :account)
    assert_instance_of(Account, @industry.build_account)
  end

  test "has_many :users" do
    assert_respond_to(@industry, :users)
    assert_instance_of(User, @industry.users.build)
  end
end
