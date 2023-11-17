class ChangeResponseBasedColumnsTypesOfAnswersAndPrompts < ActiveRecord::Migration[7.0]
  def up
    change_column :answers, :response, "varchar[] USING (string_to_array(response, ','))"
    change_column :prompts, :selector, "varchar[] USING (string_to_array(selector, ','))"
    add_column :answers, :position, :integer
  end
  
  def down
    remove_column :answers, :position
    change_column :prompts, :selector, :string
    change_column :answers, :response, :text
  end
end
