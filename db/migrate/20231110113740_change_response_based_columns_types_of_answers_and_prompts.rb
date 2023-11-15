class ChangeResponseBasedColumnsTypesOfAnswersAndPrompts < ActiveRecord::Migration[7.0]
  def up
    change_column :answers, :response, "varchar[] USING (string_to_array(response, ','))"
    change_column :prompts, :selector, "varchar[] USING (string_to_array(selector, ','))"
  end
  
  def down
    change_column :prompts, :selector, :string
    change_column :answers, :response, :text
  end
end
