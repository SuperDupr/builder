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

class ParentNodeTest < ActiveSupport::TestCase
  def setup
    @parent_node = ParentNode.create!(title: "A parent node!", question: questions(:one))
  end

  test "should inherit from Node class" do
    assert_includes(ParentNode.ancestors, Node)
  end

  test "belongs_to question association" do
    assert_respond_to @parent_node, :question
    assert_instance_of Question, @parent_node.question
  end

  test "has_many child_nodes association" do
    assert_respond_to @parent_node, :child_nodes
    assert_instance_of ChildNode, @parent_node.child_nodes.build
  end

  test "accepts_nested_attributes_for child_nodes" do
    assert_respond_to @parent_node, :child_nodes_attributes=
  end
end
