desc "It migrates the questionnaires data to produce questions inside story builders with one-to-many relationship!"

task migrate_questionnaires_data: :environment do
  ActiveRecord::Base.transaction do
    Questionnaire.all.each do |questionnaire|
      new_question = Question.new(
        questionnaire.question.attributes.except(
          "id", "created_at", "updated_at", "story_builder_id"
        )
      )

      new_question.story_builder_id = questionnaire.story_builder_id
      new_question.position = questionnaire.position
      new_question.save!
    end
  end
end
