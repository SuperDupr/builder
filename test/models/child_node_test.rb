# == Schema Information
#
# Table name: nodes
#
#  id             :bigint           not null, primary key
#  title          :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  parent_node_id :integer
#  question_id    :integer
#
require "test_helper"

class ChildNodeTest < ActiveSupport::TestCase
  def setup
    parent_node = ParentNode.create!(title: "A parent node!", question: questions(:one))
    @child_node = parent_node.child_nodes.create!(title: "A Child Node")
  end

  test "belongs_to parent_node association" do
    assert_respond_to @child_node, :parent_node
    assert_instance_of ParentNode, @child_node.parent_node
  end
end
