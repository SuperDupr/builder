class AddAiGeneratedContentToStories < ActiveRecord::Migration[7.0]
  def change
    add_column :stories, :ai_generated_content, :text
  end
end
