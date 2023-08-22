require "test_helper"

class StoryBuildersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
    sign_in(@user)
  end

  test "should get index" do
    get story_builders_path
    assert_response :success
  end

  # TODO: Once the show action is implemented, enable it.
  test "should set story_builder" do
    # story_builder = story_builders(:one)
    # get story_builder_path(story_builder)
    # assert_response :success
    # assert_equal story_builder, assigns(:story_builder)
  end
end
