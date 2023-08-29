class AddRegistrationColumnsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :work_role, :text
    add_column :users, :focus_of_communication, :text
    add_column :users, :industry_id, :integer
  end
end
