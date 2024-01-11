require "test_helper"

class StoryBuildersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
    sign_in(@user)
  end

  test "should get index" do
    @story_builder = story_builders(:one)

    get story_builders_path

    story_builders = controller.instance_variable_get(:@story_builders)
    pagy = controller.instance_variable_get(:@pagy)
    redirect_to_registration_section = controller.instance_variable_get(:@redirect_to_registration_section)
    story = controller.instance_variable_get(:@story)

    assert_includes(story_builders, @story_builder)
    assert_instance_of(Pagy, pagy)
    # removed for now
    # assert_equal(redirect_to_registration_section, true)
    assert_equal(story.new_record?, true)

    assert_response :success
  end
end
