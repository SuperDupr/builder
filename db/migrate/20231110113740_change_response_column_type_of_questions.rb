class ChangeResponseColumnTypeOfQuestions < ActiveRecord::Migration[7.0]
  def change
    change_column :answers, :response, "varchar[] USING (string_to_array(response, ','))"
  end
end
