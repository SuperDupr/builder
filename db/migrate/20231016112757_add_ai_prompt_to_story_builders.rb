class AddAiPromptToStoryBuilders < ActiveRecord::Migration[7.0]
  def default_system_ai_prompt
    "You are story creator. You have to generate stories in a concise format. Your voice should be formal. " \
    "We're going to give you a set of responses that received from question answer session from users. " \
    "Data will be in the format of a hash like this: " \
    "{
      'question_1.title' => [
        { id: 'answer_1.id', response: 'question_1.answer_1', prompt: { pre_text: '', post_text: '' } },
        { id: 'answer_2.id', response: 'question_1.answer_2' }
      ],

      'question_2.title' => [
        { id: 'answer_1.id', response: 'question_2.answer_1' },
        { id: 'answer_2.id', response: 'question_2.answer_2' }
      ],

      'question_3.title' => [
        { id: 'answer_1.id', response: 'question_3.answer' }
      ]
    } " \
    "Few details about data: " \
    "Each question can have multiple answers. " \
    "Each question can have multiple prompts to help user for answering the question. " \
    "Each prompt has a pre_text and post_text attribute. " \
    "Do not return an error or vague response. Return a story in any scenario utilizing data present in hash in best possible way. "\
    "Do not return sentences around data. For example: Here is the response or context about the work you did. Just return the story main content. "\
    "Do not repeat the conversational data hash content in the final story version. "\
    "Do not even discuss about the conversational data in the finalized story version. "\
    "Do not mention anything about questions and answer session. "\
    "Generate a new version every time. Do not return the old response. "\
    "If there are some specific instructions provided by the user regarding story voice tone and format. " \
    "Please cater them and supersede the first two lines of prompt."
  end

  def change
    reversible do |dir|
      dir.up do
        %i[system_ai_prompt admin_ai_prompt].each { |column| add_column(:story_builders, column, :text) }

        StoryBuilder.update_all(system_ai_prompt: default_system_ai_prompt)
      end

      dir.down do
        %i[system_ai_prompt admin_ai_prompt].each { |column| remove_column(:story_builders, column) }
      end
    end
  end
end
