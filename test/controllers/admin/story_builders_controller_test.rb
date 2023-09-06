require "test_helper"

class Admin::StoryBuildersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @admin = users(:admin)
    sign_in(@admin)

    @story_builder = story_builders(:one)
  end

  test "should get index" do
    get admin_story_builders_path

    story_builders = controller.instance_variable_get(:@story_builders)
    pagy = controller.instance_variable_get(:@pagy)

    assert_includes(story_builders, @story_builder)
    assert_instance_of(Pagy, pagy)

    assert_response :success
  end

  test "should get new" do
    get new_admin_story_builder_path

    story_builder = controller.instance_variable_get(:@story_builder)
    questions = controller.instance_variable_get(:@questions)
    pagy = controller.instance_variable_get(:@pagy)
    tracked_question_ids = controller.instance_variable_get(:@tracked_question_ids)

    assert_equal(story_builder.new_record?, true)
    assert_includes(questions, questions(:one))
    assert_instance_of(Pagy, pagy)
    assert_empty(tracked_question_ids)

    assert_response :success
  end

  test "should create story_builder" do
    post admin_story_builders_path, params: {
      story_builder: {
        title: "New Story Builder"
      },
      builder: {
        q_ids: [1, 2, 3]
      }
    }

    assert_equal(controller.send(:attach_questions_to_builder).first.has_key?("id"), true)
    assert_redirected_to admin_story_builders_path
  end

  test "should show story_builder" do
    @story_builder.questionnaires.create!(question_id: questions(:one).id)

    get admin_story_builder_path(@story_builder.id)

    questionnaires = controller.instance_variable_get(:@questionnaires)
    questionnaires_size = controller.instance_variable_get(:@questionnaires_size)

    assert_includes(questionnaires, @story_builder.questionnaires.first)
    assert_equal(questionnaires_size, 2)

    assert_response :success
  end

  test "should get edit" do
    get admin_story_builder_path(@story_builder.id)

    # pagy = controller.instance_variable_get(:@pagy)
    # tracked_question_ids = controller.instance_variable_get(:@tracked_question_ids)

    assert_response :success
  end

  # test "should update story_builder" do
  #   patch :update, params: { id: @story_builder, story_builder: { title: "Updated Story Builder" } }
  #   assert_redirected_to admin_story_builders_path
  # end

  # test "should destroy story_builder" do
  #   assert_difference('StoryBuilder.count', -1) do
  #     delete :destroy, params: { id: @story_builder }
  #   end

  #   assert_redirected_to admin_story_builders_path
  # end

  # test "should sort questions" do
  #   # You can write a test for the sort_questions action here
  #   # Make sure to pass the required parameters for sorting
  #   # Assert the expected JSON response and behavior
  # end

  # Add more tests for private and helper methods if needed
end
