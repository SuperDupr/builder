class CreatePrompts < ActiveRecord::Migration[7.0]
  def change
    create_table :prompts do |t|
      t.string :pre_text
      t.string :post_text
      t.references :question, foreign_key: true

      t.timestamps
    end
  end
end
