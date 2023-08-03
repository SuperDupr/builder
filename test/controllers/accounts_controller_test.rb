require "test_helper"

class AccountControllerTest < ActionDispatch::IntegrationTest
  def setup
    sign_in(users(:one))
  end

  test "GET :index" do
    get accounts_path

    account_users = controller.instance_variable_get(:@account_users)
    pagy_2 = controller.instance_variable_get(:@pagy_2)

    assert_includes(account_users, account_users(:one))
    assert_instance_of(Pagy, pagy_2)
  end

  test "GET :organization_users" do
    get organization_users_account_path(accounts(:one))

    account_users = controller.instance_variable_get(:@account_users)
    pagy = controller.instance_variable_get(:@pagy)

    assert_includes(account_users, account_users(:one))
    assert_instance_of(Pagy, pagy)
  end

  test "GET :invited_users" do
    get invited_users_account_path(accounts(:company))

    account_invitations = controller.instance_variable_get(:@account_invitations)
    pagy = controller.instance_variable_get(:@pagy)

    assert_includes(account_invitations, account_invitations(:one))
    assert_instance_of(Pagy, pagy)
  end
end
