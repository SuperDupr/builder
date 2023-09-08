class AddPositionToQuestionnaire < ActiveRecord::Migration[7.0]
  def change
    add_column :questionnaires, :position, :bigint
  end
end
