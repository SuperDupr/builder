require "test_helper"

class Admin::AccountInvitationsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @admin = users(:admin)
    sign_in(@admin)
  end

  test "POST :create" do
    account = accounts(:without_owner)

    post create_account_user_invitation_path(account), params: {account_invitation: {first_name: "Sanders", last_name: "Cusak", email: "sanders@example.com", roles: "member", team_id: teams(:one).id}}

    account_invitation = controller.instance_variable_get(:@account_invitation)
    # user = User.find_by(email: "sanders@example.com")

    # res = AccountInvitation.find(account_invitation.id)

    # puts account_invitation.methods

    # puts account_invitation.persisted?
    # puts account_invitation.new_record?
    # puts account_invitation.class

    # Testing the scenario when account owner is not present!
    # TODO: Fix assertions relevant to account_invitation object

    # assert_equal(account_invitation.new_record?, true)
    # assert_equal(account.owner_id, user.id)
    assert_respond_to(account_invitation, :create_user_reflection)
    assert_equal(account_invitation.team_name, "MyString")
    assert_enqueued_jobs(1)
  end
end
