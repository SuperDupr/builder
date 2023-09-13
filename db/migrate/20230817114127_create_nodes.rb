class CreateNodes < ActiveRecord::Migration[7.0]
  def change
    create_table :nodes do |t|
      t.string :title
      t.integer :parent_node_id
      t.integer :question_id

      t.timestamps
    end
  end
end
