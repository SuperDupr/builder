class AddMultipleNodeSelectionToggleInQuestions < ActiveRecord::Migration[7.0]
  def change
    add_column :questions, :multiple_node_selection, :boolean, default: false
  end
end
