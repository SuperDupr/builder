class CreateAccountInvitations < ActiveRecord::Migration[6.0]
  def change
    create_table :account_invitations do |t|
      t.belongs_to :account, null: false, foreign_key: true
      t.belongs_to :invited_by, null: false, foreign_key: {to_table: :users}
      t.string :token, null: false
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false
      t.string :team_name
      t.integer :team_id
      t.jsonb :roles, null: false, default: {}

      t.timestamps
    end
    add_index :account_invitations, :token, unique: true
  end
end
