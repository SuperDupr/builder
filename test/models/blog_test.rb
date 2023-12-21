# == Schema Information
#
# Table name: blogs
#
#  id            :bigint           not null, primary key
#  public_access :boolean          default(FALSE)
#  published     :boolean          default(FALSE)
#  title         :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
require "test_helper"

class BlogTest < ActiveSupport::TestCase
  test "Validations" do
    blog = Blog.new(title: "")

    assert(blog.invalid?, true)
  end

  test "Associations" do
    @associations_reflector = Blog.reflect_on_all_associations

    # assoc_classes = @associations_reflector.map { |assoc_ref| assoc_ref.class }
    assoc_names = @associations_reflector.map { |assoc_ref| assoc_ref.name }

    # assert_includes(assoc_classes, ActiveRecord::Reflection::BelongsToReflection)
    assert_includes(assoc_names, :taggings)
    assert_includes(assoc_names, :tags)
    assert_includes(assoc_names, :tag_taggings)
  end
end
