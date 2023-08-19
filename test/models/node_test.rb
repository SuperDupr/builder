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

class NodeTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
