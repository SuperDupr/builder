class AddSelectorToPrompts < ActiveRecord::Migration[7.0]
  def change
    add_column :prompts, :selector, :string, array: true, default: []
  end
end
