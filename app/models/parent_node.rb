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
class ParentNode < Node
  # Associations
  belongs_to :question
  has_many :child_nodes, dependent: :destroy

  accepts_nested_attributes_for :child_nodes, reject_if: :all_blank, allow_destroy: true
end
