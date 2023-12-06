class AddSubtitleToQuestion < ActiveRecord::Migration[7.0]
  def change
    add_column :questions, :subtitle, :text
  end
end
