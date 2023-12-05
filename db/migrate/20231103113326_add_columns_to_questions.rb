class AddColumnsToQuestions < ActiveRecord::Migration[7.0]
  def change
    add_column :questions, :active, :boolean, default: true
    add_column :questions, :story_builder_id, :integer
    add_column :questions, :position, :integer
    add_column :questions, :ai_prompt_attached, :boolean, default: false
    add_column :questions, :ai_prompt, :text
  end
end
