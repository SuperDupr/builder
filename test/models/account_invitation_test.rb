# == Schema Information
#
# Table name: account_invitations
#
#  id            :bigint           not null, primary key
#  email         :string           not null
#  first_name    :string
#  imported      :boolean          default(FALSE)
#  last_name     :string
#  name          :string
#  roles         :jsonb            not null
#  team_name     :string
#  token         :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  account_id    :bigint           not null
#  invited_by_id :bigint
#  team_id       :integer
#
# Indexes
#
#  index_account_invitations_on_account_id     (account_id)
#  index_account_invitations_on_invited_by_id  (invited_by_id)
#  index_account_invitations_on_token          (token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (invited_by_id => users.id)
#
require "test_helper"

class AccountInvitationTest < ActiveSupport::TestCase
  setup do
    @account_invitation = account_invitations(:one)
    @account = @account_invitation.account
  end

  test "cannot invite same email twice" do
    invitation = @account.account_invitations.create(name: "whatever", email: @account_invitation.email)
    assert_not invitation.valid?
  end

  test "#create_account_user" do
    user = users(:invited)
    assert_difference "AccountUser.count" do
      account_user = @account_invitation.accept!(user)
      assert account_user.persisted?
      assert_equal user, account_user.user
      assert_equal(@account_invitation.roles, account_user.roles)
    end

    assert_raises ActiveRecord::RecordNotFound do
      @account_invitation.reload
    end
  end

  test "reject" do
    assert_difference "AccountInvitation.count", -1 do
      @account_invitation.reject!
    end
  end

  test "accept sends notifications account owner and inviter" do
    assert_difference "Notification.count", 2 do
      account_invitations(:two).accept!(users(:invited))
    end
    assert_equal @account, Notification.last.account
    assert_equal users(:invited), Notification.last.params[:user]
  end

  test "#create_user_reflection" do
    assert_difference("User.count", 1) do
      user, _random_password = @account_invitation.create_user_reflection

      assert_instance_of(User, user)
      assert_equal(@account_invitation.first_name, user.first_name)
      assert_equal(@account_invitation.last_name, user.last_name)
      assert_equal(@account_invitation.email, user.email)
    end
  end

  test "#associate_objects_with_user" do
    user = User.new
    @account_invitation.update(team_id: teams(:one).id)
    @account_invitation.associate_objects_with_user(user)

    assert_equal(user.team_id, @account_invitation.team_id)
    assert_not_nil(user.invitation_accepted_at)
  end

  test "#accept!" do
    user = users(:invited)
    account_user = @account_invitation.accept!(user, true)

    assert_not_nil(user.invitation_accepted_at)
    assert_equal(user, account_user.user)
  end

  test "#full_name" do
    name = @account_invitation.full_name

    assert_includes(name, @account_invitation.first_name)
    assert_includes(name, @account_invitation.last_name)
  end

  test "self.accessible_attributes" do
    attrs = AccountInvitation.accessible_attributes

    assert_includes(attrs, "email")
    assert_includes(attrs, "first_name")
    assert_includes(attrs, "last_name")
    assert_includes(attrs, "team_name")
    assert_includes(attrs, "roles")
  end

  test "self.sanitize_row_data" do
    teams = {"Team A" => 1, "Team B" => 2}
    roles = [{"admin" => true}, {"member" => true}]

    # Test case 1: Existing team name
    row1 = {"team_name" => "Team A", "roles" => "admin"}
    sanitized_row1 = AccountInvitation.sanitize_row_data(row1, teams, roles)
    assert_equal(1, sanitized_row1["team_id"])
    assert_equal({"admin" => true}, sanitized_row1["roles"])

    # Test case 2: Non-existing team name
    row2 = {"team_name" => "Team C", "roles" => "member"}
    sanitized_row2 = AccountInvitation.sanitize_row_data(row2, teams, roles)
    assert_nil(sanitized_row2["team_id"])
    assert_equal({"member" => true}, sanitized_row2["roles"])

    # Test case 3: Existing role name
    row3 = {"team_name" => "Team B", "roles" => "member"}
    sanitized_row3 = AccountInvitation.sanitize_row_data(row3, teams, roles)
    assert_equal(2, sanitized_row3["team_id"])
    assert_equal({"member" => true}, sanitized_row3["roles"])

    # Test case 4: Non-existing role name
    row4 = {"team_name" => "Team B", "roles" => "guest"}
    sanitized_row4 = AccountInvitation.sanitize_row_data(row4, teams, roles)
    assert_equal(2, sanitized_row4["team_id"])
    assert_equal({"member" => true}, sanitized_row4["roles"])
  end

  test "self.persist_records" do
    # Create an array of mock objects to be used as records
    records = Array.new(10) { Minitest::Mock.new }

    # Set expectations for each mock object
    records.each do |object|
      object.expect(:save_and_send_invite, true)
    end

    # Call the persist_records method
    AccountInvitation.persist_records(records)

    # Verify that the save_and_send_invite method was called for each object
    records.each do |object|
      object.verify
    end
  end

  test "self.import_file" do
    account = accounts(:one)
    file_name = "example_file.csv"

    # Stub the BulkImportUsersJob.perform_later method
    mock_job = Minitest::Mock.new
    mock_job.expect(:perform_later, nil, [file_name, account])

    # Set Rails environment to something other than production
    AccountInvitation.import_file(file_name, account)
  end
end
