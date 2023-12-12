class CreateBlogs < ActiveRecord::Migration[7.0]
  def change
    create_table :blogs do |t|
      t.string :title
      t.boolean :published, default: false

      t.timestamps
    end

    reversible do |dir|
      dir.up do
        puts "*** Destroying old blog rich text attachments ***"
        ActionText::RichText.where(record_type: "Blog").destroy_all

        puts "*** Seeding Blogs ***"
        50.times do |i|
          Blog.create(
            title: "Blog - #{i}",
            body: "ActionText content",
            published: false
          )
        end
      end

      dir.down {}
    end
  end
end
