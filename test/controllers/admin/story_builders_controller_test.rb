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
    assert_equal(controller.send(:attach_questions_to_builder).first.has_key?("id"), true)
    assert_equal(controller.send(:detach_questions_from_builder), 0)
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

    assert_equal(parsed_response["questionnaire"]["position"], 2)
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

  test "#is_question_id_tracked?" do
    get admin_story_builders_path

    controller.instance_variable_set(:@tracked_question_ids, [questions(:one).id])

    assert_equal(controller.send(:is_question_id_tracked?, questions(:one).id), true)
  end

  test "#attach_questions_to_builder" do
    question_1 = questions(:one)
    question_2 = questions(:two)

    patch admin_story_builder_path(
      @story_builder,
      story_builder: {
        title: "Updated Story Builder"
      },
      builder: {
        q_ids: [question_1.id, question_2.id]
      }
    )

    controller.instance_variable_set(:@tracked_question_ids, [])
    attached_questions_response = controller.send(:attach_questions_to_builder)
    attached_question_ids = attached_questions_response.rows.flatten

    assert_equal(attached_question_ids.count, 2)
  end

  test "#detach_questions_from_builder" do
    question_1 = questions(:one)
    question_2 = questions(:two)

    @story_builder.questionnaires.destroy_all
    @story_builder.questionnaires.create!(question_id: question_1.id, position: 1)
    @story_builder.questionnaires.create!(question_id: question_2.id, position: 2)

    patch admin_story_builder_path(
      @story_builder,
      story_builder: {
        title: "Updated Story Builder"
      },
      builder: {
        q_ids: [question_2.id]
      }
    )

    controller.instance_variable_set(:@tracked_question_ids, [question_1.id, question_2.id])
    detached_questions_response = controller.send(:detach_questions_from_builder)
    detached_question_ids = detached_questions_response

    assert_equal(detached_question_ids, 0)
  end
end
