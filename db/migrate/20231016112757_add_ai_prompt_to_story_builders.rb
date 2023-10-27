class AddAiPromptToStoryBuilders < ActiveRecord::Migration[7.0]
  def change
    add_column(:story_builders, :admin_ai_prompt, :text)
  end
end
