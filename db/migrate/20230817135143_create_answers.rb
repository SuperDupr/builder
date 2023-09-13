class CreateAnswers < ActiveRecord::Migration[7.0]
  def change
    create_table :answers do |t|
      t.text :response
      t.references :story, foreign_key: true
      t.references :question, foreign_key: true

      t.timestamps
    end
  end
end
