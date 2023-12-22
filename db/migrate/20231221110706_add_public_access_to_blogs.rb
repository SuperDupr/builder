class AddPublicAccessToBlogs < ActiveRecord::Migration[7.0]
  def change
    add_column :blogs, :public_access, :boolean, default: false
  end
end
