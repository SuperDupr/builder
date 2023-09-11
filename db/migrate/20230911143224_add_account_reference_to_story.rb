class AddAccountReferenceToStory < ActiveRecord::Migration[7.0]
  def change
    add_reference :stories, :account, foreign_key: true
  end
end
