# == Schema Information
#
# Table name: nodes
#
#  id         :bigint           not null, primary key
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class ParentNode < Node
  # Associations
  belongs_to :question
  has_many :sub_nodes, dependent: :destroy
end
