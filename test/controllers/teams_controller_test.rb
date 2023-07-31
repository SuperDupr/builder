require "test_helper"

class TeamsControllerTest < ActionDispatch::IntegrationTest
  def setup
    sign_in(users(:one))
  end

  test "GET :index" do
    get teams_path

    teams = controller.instance_variable_get(:@teams)
    pagy = controller.instance_variable_get(:@pagy)

    assert_equal(teams.first.name, "MyString")
    assert_instance_of(Pagy, pagy)
    assert_response(:success)
  end

  test "GET :new" do
    get new_team_path

    team = controller.instance_variable_get(:@team)

    assert_instance_of(Team, team)
    assert_not_equal(team.persisted?, true)
    assert_response(:success)
  end

  test "POST :create" do
    post teams_path, params: {team: {name: "New Team"}}

    team = controller.instance_variable_get(:@team)

    assert_equal(team.name, "New Team")
    assert_equal(team.persisted?, true)
    assert_response(:redirect)
  end

  test "GET :edit" do
    get edit_team_path(teams(:one))

    team = controller.instance_variable_get(:@team)

    assert_equal(team.name, "MyString")
    assert_equal(response["Content-Type"], "text/html; charset=utf-8")
    assert_response(:success)
  end

  test "PATCH :update" do
    patch team_path(teams(:one)), params: {team: {name: "MyString edited"}}

    team = controller.instance_variable_get(:@team)

    assert_equal(team.name, "MyString edited")
    assert_response(:redirect)
  end

  test "GET :show" do
    get team_path(teams(:one))

    team = controller.instance_variable_get(:@team)

    assert_equal(team.name, "MyString")
    assert_equal(response["Content-Type"], "text/html; charset=utf-8")
    assert_response(:success)
  end

  test "DELETE :destroy" do
    teams(:one)
    teams(:two)

    assert_equal(Team.count, 2)

    delete team_path(teams(:one))

    assert_equal(Team.count, 1)
    assert_equal(Team.first.account, accounts(:two))
    assert_response(:redirect)
  end
end
