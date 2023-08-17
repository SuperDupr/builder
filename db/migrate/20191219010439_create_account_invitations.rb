class CreateAccountInvitations < ActiveRecord::Migration[6.0]
  def change
    create_table :account_invitations do |t|
      t.belongs_to :account, null: false, foreign_key: true
      t.belongs_to :invited_by, foreign_key: {to_table: :users}
      t.string :token, null: false
      t.string :first_name
      t.string :last_name
      t.string :name
      t.string :email, null: false
      t.string :team_name
      t.integer :team_id
      t.boolean :imported, default: false
      t.jsonb :roles, null: false, default: {}

      t.timestamps
    end
    add_index :account_invitations, :token, unique: true
  end
end
