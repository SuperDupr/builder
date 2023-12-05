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
    pagy = controller.instance_variable_get(:@pagy)
    tracked_question_ids = controller.instance_variable_get(:@tracked_question_ids)

    assert_equal(story_builder.new_record?, true)
    # assert_includes(questions, questions(:one))
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

    assert_redirected_to admin_story_builders_path
  end

  test "should show story_builder" do
    @story_builder.questionnaires.create!(question_id: questions(:one).id)

    get admin_story_builder_path(@story_builder.id)

    assert_response :success
  end

  test "should get edit" do
    get edit_admin_story_builder_path(@story_builder.id)

    pagy = controller.instance_variable_get(:@pagy)
    questions = controller.instance_variable_get(:@questions)
    tracked_question_ids = controller.instance_variable_get(:@tracked_question_ids)

    question = @story_builder.questionnaires.first.question

    assert_instance_of(Pagy, pagy)
    assert_includes(questions, question)
    assert_includes(tracked_question_ids, question.id)

    assert_response :success
  end

  test "should update story_builder" do
    @story_builder.questionnaires.create!(question_id: questions(:one).id)

    patch admin_story_builder_path(
      {
        id: @story_builder,
        story_builder: {
          title: "Updated Story Builder"
        },
        builder: {
          q_ids: [1, 2, 3]
        }
      }
    )

    tracked_question_ids = controller.instance_variable_get(:@tracked_question_ids)
    story_builder = controller.instance_variable_get(:@story_builder)

    assert_includes(tracked_question_ids, questions(:one).id)
    assert_equal(story_builder.title, "Updated Story Builder")
    assert_redirected_to admin_story_builders_path
  end

  test "should destroy story_builder" do
    assert_difference("StoryBuilder.count", -1) do
      delete admin_story_builder_path(@story_builder)
    end

    assert_redirected_to admin_story_builders_path
  end

  test "should sort questions" do
    @story_builder.questionnaires.create!(question_id: questions(:one).id)

    patch sort_questions_admin_story_builder_path(@story_builder, {
      question_id: questions(:one).id,
      question: {
        position: 2
      }
    }), xhr: true

    parsed_response = JSON.parse(response.body)

    assert_equal(parsed_response["question"]["position"], 2)
    assert_response(:success)
  end

  # Private methods block

  test "#questions_exist?" do
    patch admin_story_builder_path(
      {
        id: @story_builder,
        story_builder: {
          title: "Updated Story Builder"
        },
        builder: {
          q_ids: [1, 2, 3]
        }
      }
    )

    assert_equal(controller.send(:questions_exist?), true)
  end
end
