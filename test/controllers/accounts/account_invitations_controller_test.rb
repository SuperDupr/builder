require "test_helper"

class Accounts::AccountInvitationsControllerTest < ActionDispatch::IntegrationTest
  def setup
    sign_in(users(:one))
  end

  test "GET :new" do
    get new_account_account_invitation_path(accounts(:one))

    account_invitation = controller.instance_variable_get(:@account_invitation)
    teams = controller.instance_variable_get(:@teams)

    assert_instance_of(AccountInvitation, account_invitation)
    assert_equal(teams.first.name, "MyString")
    assert_response(:success)
  end

  test "POST :create" do
    post account_account_invitations_path(accounts(:one)), params: {
      account_invitation: {
        first_name: "Sanders",
        last_name: "Cusak",
        email: "sanders@example.com",
        roles: "member"
      }
    }

    account_invitation = controller.instance_variable_get(:@account_invitation)

    assert_equal(account_invitation.persisted?, true)
    assert_equal(account_invitation.invited_by_id, users(:one).id)
    assert_enqueued_jobs(1)
    assert_response(:redirect)
  end

  test "POST :bulk_import" do
    post bulk_import_org_account_invitations_path(
      accounts(:one).id,
      account_id: accounts(:one).id
    ), params: {file: fixture_file_upload("fte_users_import.xlsx")}

    assert_enqueued_jobs(1)
    assert_response(:redirect)
  end
end
