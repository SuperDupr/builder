class CreateStories < ActiveRecord::Migration[7.0]
  def change
    create_table :stories do |t|
      t.string :title
      t.boolean :private_access, default: true
      t.boolean :viewable, default: false
      t.integer :status, default: 0
      t.references :creator, foreign_key: {to_table: "users"}
      t.references :story_builder, foreign_key: true
      t.references :account, foreign_key: true

      t.timestamps
    end
  end
end
