class AddPromptIdToAnswers < ActiveRecord::Migration[7.0]
  def change
    add_column :answers, :prompt_id, :integer
  end
end
