class ChangeResponseBasedColumnsTypesOfAnswersAndPrompts < ActiveRecord::Migration[7.0]
  def up
    change_column :answers, :response, "varchar[] USING (string_to_array(response, ','))"
    change_column :prompts, :selector, "varchar[] USING (string_to_array(selector, ','))"
    add_column :answers, :position, :integer
    add_column :prompts, :position, :integer

    Question.all.each do |question|
      question.answers.order(:updated_at).each.with_index(1) do |answer, index|
        answer.update_column :position, index
      end

      question.prompts.order(:updated_at).each.with_index(1) do |prompt, index|
        prompt.update_column :position, index
      end
    end
  end
  
  def down
    remove_column :prompts, :position
    remove_column :answers, :position
    change_column :prompts, :selector, :string
    change_column :answers, :response, :text
  end
end
