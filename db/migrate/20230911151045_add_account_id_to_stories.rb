class AddAccountIdToStories < ActiveRecord::Migration[7.0]
  def change
    add_column :answers, :story_id, :integer
  end
end
