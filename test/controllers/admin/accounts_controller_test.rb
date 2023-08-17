require "test_helper"

class Admin::AccountsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @admin = users(:admin)
    sign_in(@admin)
  end

  test "PATCH :manage_access" do
    patch manage_access_admin_account_path(accounts(:one))

    parsed_response = JSON.parse(response.body)

    assert_equal(response["Content-Type"], "application/json; charset=utf-8")
    assert_includes(parsed_response.keys, "access")
    assert_includes([TrueClass, FalseClass], parsed_response["access"].class)
  end
end
