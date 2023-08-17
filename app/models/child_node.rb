# == Schema Information
#
# Table name: nodes
#
#  id         :bigint           not null, primary key
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class ChildNode < Node
  # Associations
  belongs_to :parent_node
end
