class AddPrivateToBlogs < ActiveRecord::Migration[7.0]
  def change
    add_column :blogs, :private, :boolean, default: true
  end
end
