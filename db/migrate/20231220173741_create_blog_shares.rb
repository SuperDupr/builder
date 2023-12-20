class CreateBlogShares < ActiveRecord::Migration[7.0]
  def change
    create_table :blog_shares do |t|
      t.references :account, null: false, foreign_key: true
      t.references :blog, null: false, foreign_key: true

      t.timestamps
    end
  end
end
