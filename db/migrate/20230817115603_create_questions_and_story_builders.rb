class CreateQuestionsAndStoryBuilders < ActiveRecord::Migration[7.0]
  def change
    create_table :questions do |t|
      t.string :title

      t.timestamps
    end

    create_table :story_builders do |t|
      t.string :title

      t.timestamps
    end

    create_table :questionnaires do |t|
      t.belongs_to :question
      t.belongs_to :story_builder
      t.integer :position
    end
  end
end
