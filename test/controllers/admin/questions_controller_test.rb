require "test_helper"

class Admin::QuestionsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @admin = users(:admin)
    sign_in(@admin)
  end

  test "should get index" do
    get admin_questions_path
    assert_response :success
  end

  test "should get show" do
    question = questions(:one)
    get admin_question_path(question)
    assert_response :success
  end

  test "should get new" do
    get new_admin_question_path
    assert_response :success
  end

  test "should create question" do
    post admin_questions_path, params: {
      question: {
        title: "New Question",
        prompts_attributes: [{pre_text: "Pre", post_text: "Post"}],
        parent_nodes_attributes: [
          {title: "Parent Node", child_nodes_attributes: [{title: "Child Node"}]}
        ]
      },
      fallback_builder_id: story_builders(:one).id
    }

    question = controller.instance_variable_get(:@question)

    assert_equal "Question added successfully!", flash[:notice]
    assert_equal question.parent_nodes.first.title, "Parent Node"
    assert_equal question.prompts.first.pre_text, "Pre"
  end

  test "should get edit" do
    question = questions(:one)
    get edit_admin_question_path(question)
    assert_response :success
  end

  test "should update question" do
    question = questions(:one)
    patch admin_question_path(question), params: {
      question: {title: "Updated Title"}
    }

    assert_redirected_to admin_questions_path
    question.reload
    assert_equal "Updated Title", question.title
  end

  test "should destroy question" do
    question = questions(:one)

    delete admin_question_path(question)

    assert_redirected_to admin_questions_path
    assert_equal "Question was successfully destroyed.", flash[:notice]
  end
end
