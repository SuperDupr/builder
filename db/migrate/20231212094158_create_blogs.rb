class CreateBlogs < ActiveRecord::Migration[7.0]
  def change
    create_table :blogs do |t|
      t.string :title
      t.boolean :published, default: false

      t.timestamps
    end
  end
end
