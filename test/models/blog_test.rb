# == Schema Information
#
# Table name: blogs
#
#  id         :bigint           not null, primary key
#  published  :boolean          default(FALSE)
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require "test_helper"

class BlogTest < ActiveSupport::TestCase
  test "Validations" do
    blog = Blog.new(title: "")

    assert(blog.invalid?, true)
  end
end
