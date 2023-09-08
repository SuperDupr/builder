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
  # test "the truth" do
  #   assert true
  # end
end
