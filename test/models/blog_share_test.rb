# == Schema Information
#
# Table name: blog_shares
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  account_id :bigint           not null
#  blog_id    :bigint           not null
#
# Indexes
#
#  index_blog_shares_on_account_id  (account_id)
#  index_blog_shares_on_blog_id     (blog_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (blog_id => blogs.id)
#
require "test_helper"

class BlogShareTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
